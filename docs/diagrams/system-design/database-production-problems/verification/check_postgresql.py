"""Synthetic checks ONLY for the separately initialized local scratch server.
Requires psycopg 3. Never points at port 5432 or at the live paymesh database.
"""
import psycopg, threading, concurrent.futures, json, uuid
from pathlib import Path
from psycopg import IsolationLevel
CONNECT=dict(host='/tmp/paymesh-schema-check',port=55439,user='labcheck',dbname='postgres',connect_timeout=5)
results=[]
def conn():
 c=psycopg.connect(**CONNECT);c.execute("SET statement_timeout='10s'");c.execute("SET lock_timeout='8s'");c.commit();return c
def val(sql):
 with conn() as c:return c.execute(sql).fetchone()[0]
def runsql(sql):
 with conn() as c:c.execute(sql)
def test(name, fn):
 fn();results.append({'case':name,'result':'PASS'});print('PASS',name)
def error_state(c,sql,state):
 try:c.execute(sql)
 except psycopg.Error as e:assert e.sqlstate==state,(e.sqlstate,state)
 else:raise AssertionError('Expected '+state)
def parallel(fn):
 barrier=threading.Barrier(2,timeout=8)
 with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
  a=pool.submit(fn,0,barrier);b=pool.submit(fn,1,barrier)
  return [a.result(timeout=12),b.result(timeout=12)]
with conn() as c:
 assert c.execute("select current_user,current_database(),current_setting('port')").fetchone()==('labcheck','postgres','55439')
 version=c.execute('show server_version').fetchone()[0]
 c.execute('CREATE SCHEMA atlas_check')
 c.execute('CREATE TABLE atlas_check.records(id int primary key, value int not null check(value>0))')
 c.execute('CREATE TABLE atlas_check.accounts(id int primary key,balance bigint not null,version bigint not null default 0)')
 c.execute('CREATE TABLE atlas_check.requests(merchant text not null,key text not null,amount bigint not null,unique(merchant,key))')
 c.execute('CREATE TABLE atlas_check.refunds(id int primary key,captured bigint not null,reserved bigint not null check(reserved>=0 and reserved<=captured))')
 c.execute('CREATE TABLE atlas_check.coordinator(id int primary key)')
 c.execute('INSERT INTO atlas_check.coordinator VALUES(1)')
 c.execute('CREATE TABLE atlas_check.routes(id int primary key,enabled boolean not null)')
 c.execute('CREATE TABLE atlas_check.deferred(id int unique deferrable initially deferred)')
 c.execute('CREATE TABLE atlas_check.parent(id int primary key)')
 c.execute('CREATE TABLE atlas_check.child(id int primary key,pid int references atlas_check.parent(id))')

def commit():
 runsql('INSERT INTO atlas_check.records VALUES(1,1),(2,2)');assert val('SELECT count(*) FROM atlas_check.records')==2

def rollback():
 with conn() as c:
  c.execute('INSERT INTO atlas_check.records VALUES(3,3)');error_state(c,'INSERT INTO atlas_check.records VALUES(4,0)','23514');c.rollback()
 assert val('SELECT count(*) FROM atlas_check.records WHERE id in (3,4)')==0

def savepoint():
 with conn() as c:
  c.execute('INSERT INTO atlas_check.records VALUES(5,5)');c.execute('SAVEPOINT optional');c.execute('INSERT INTO atlas_check.records VALUES(6,6)');c.execute('ROLLBACK TO optional')
 assert val('SELECT count(*) FROM atlas_check.records WHERE id=5')==1
 assert val('SELECT count(*) FROM atlas_check.records WHERE id=6')==0

def aborted():
 with conn() as c:
  error_state(c,'INSERT INTO atlas_check.records VALUES(1,1)','23505');error_state(c,'SELECT 1','25P02');c.rollback();assert c.execute('SELECT 1').fetchone()[0]==1

def deferred():
 with conn() as c:
  c.execute('INSERT INTO atlas_check.deferred VALUES(1),(1)')
  try:c.commit()
  except psycopg.Error as e:assert e.sqlstate=='23505'
  else:raise AssertionError('Commit must fail')
 assert val('SELECT count(*) FROM atlas_check.deferred')==0

def duplicates():
 def worker(i,b):
  with conn() as c:
   assert c.execute("SELECT count(*) FROM atlas_check.requests WHERE merchant='m' AND key='k'").fetchone()[0]==0
   b.wait()
   row=c.execute("INSERT INTO atlas_check.requests VALUES('m','k',100) ON CONFLICT(merchant,key) DO NOTHING RETURNING amount").fetchone()
   return row is not None
 assert sorted(parallel(worker))==[False,True]
 assert val("SELECT count(*) FROM atlas_check.requests WHERE merchant='m' AND key='k'")==1
 runsql("INSERT INTO atlas_check.requests VALUES('another','k',100)");assert val("SELECT count(*) FROM atlas_check.requests WHERE key='k'")==2

def lost_update():
 runsql('INSERT INTO atlas_check.accounts VALUES(1,100,0)')
 def worker(i,b):
  with conn() as c:
   n=c.execute('SELECT balance FROM atlas_check.accounts WHERE id=1').fetchone()[0];b.wait();c.execute('UPDATE atlas_check.accounts SET balance=%s WHERE id=1',(n-(i+1)*10,))
 parallel(worker);assert val('SELECT balance FROM atlas_check.accounts WHERE id=1') in (80,90)

def optimistic():
 runsql('UPDATE atlas_check.accounts SET balance=100,version=0 WHERE id=1')
 def worker(i,b):
  with conn() as c:
   balance,version=c.execute('SELECT balance,version FROM atlas_check.accounts WHERE id=1').fetchone();b.wait()
   return c.execute('UPDATE atlas_check.accounts SET balance=%s,version=version+1 WHERE id=1 AND version=%s',(balance-(i+1)*10,version)).rowcount
 assert sorted(parallel(worker))==[0,1];assert val('SELECT version FROM atlas_check.accounts WHERE id=1')==1

def guarded_refunds():
 runsql('INSERT INTO atlas_check.refunds VALUES(1,100,0)')
 def worker(i,b):
  with conn() as c:
   b.wait();return c.execute('UPDATE atlas_check.refunds SET reserved=reserved+80 WHERE id=1 AND reserved<=captured-80 RETURNING reserved').fetchone() is not None
 assert sorted(parallel(worker))==[False,True];assert val('SELECT reserved FROM atlas_check.refunds WHERE id=1')==80

def skew():
 runsql('INSERT INTO atlas_check.routes VALUES(1,true),(2,true)')
 def worker(i,b):
  with conn() as c:
   c.isolation_level=IsolationLevel.REPEATABLE_READ
   assert c.execute('SELECT count(*) FROM atlas_check.routes WHERE enabled').fetchone()[0]==2;b.wait();c.execute('UPDATE atlas_check.routes SET enabled=false WHERE id=%s',(i+1,))
 parallel(worker);assert val('SELECT count(*) FROM atlas_check.routes WHERE enabled')==0

def parent_lock():
 runsql('UPDATE atlas_check.routes SET enabled=true')
 def worker(i,b):
  with conn() as c:
   b.wait();c.execute('SELECT id FROM atlas_check.coordinator WHERE id=1 FOR UPDATE')
   if c.execute('SELECT count(*) FROM atlas_check.routes WHERE enabled').fetchone()[0]>1:
    c.execute('UPDATE atlas_check.routes SET enabled=false WHERE id=%s',(i+1,));return True
   return False
 assert sorted(parallel(worker))==[False,True];assert val('SELECT count(*) FROM atlas_check.routes WHERE enabled')==1

def constraint_states():
 for sql,state in [("INSERT INTO atlas_check.records VALUES(7,NULL)",'23502'),('INSERT INTO atlas_check.child VALUES(1,999)','23503'),("SELECT 'not-a-uuid'::uuid",'22P02'),("SELECT '9223372036854775808'::bigint",'22003')]:
  with conn() as c:error_state(c,sql,state);c.rollback()

def null_check():
 runsql('CREATE TABLE atlas_check.null_demo(value int CHECK(value>0));INSERT INTO atlas_check.null_demo VALUES(NULL)')
 assert val('SELECT count(*) FROM atlas_check.null_demo WHERE value IS NULL')==1

def money():
 assert str(val('SELECT 0.29::numeric*100'))=='29.00'
 assert str(val('SELECT 1.239::numeric(5,2)'))=='1.24'

def defaults():
 runsql('CREATE TABLE atlas_check.defaults(id int,value int NOT NULL DEFAULT 7);INSERT INTO atlas_check.defaults(id) VALUES(1)')
 assert val('SELECT value FROM atlas_check.defaults WHERE id=1')==7
 with conn() as c:error_state(c,'INSERT INTO atlas_check.defaults VALUES(2,NULL)','23502');c.rollback()

def timezones():
 with conn() as c:
  c.execute("SET TIME ZONE 'UTC'");a=c.execute("SELECT extract(epoch from '2026-01-01T12:00:00Z'::timestamptz)").fetchone()[0]
  c.execute("SET TIME ZONE 'Europe/Berlin'");b=c.execute("SELECT extract(epoch from '2026-01-01T12:00:00Z'::timestamptz)").fetchone()[0]
  assert a==b

def live_table_copy():
 # This is the restored schema in the scratch server, NOT the live table.
 with conn() as c:
  c.execute("INSERT INTO paymesh.transactions(id,merchant_id,request_key,amount_minor,currency) VALUES(%s,'synthetic','r',100,'EUR')",(uuid.uuid4(),))
  assert c.execute("SELECT status FROM paymesh.transactions WHERE merchant_id='synthetic'").fetchone()[0]=='CREATED'
 with conn() as c:error_state(c,"UPDATE paymesh.transactions SET status='SUCCESS' WHERE merchant_id='synthetic'",'23514');c.rollback()
 with conn() as c:
  try:c.execute("INSERT INTO paymesh.transactions(id,merchant_id,request_key,amount_minor,currency) VALUES(%s,'synthetic','r',100,'EUR')",(uuid.uuid4(),))
  except psycopg.Error as e:assert e.sqlstate=='23505';c.rollback()
  else:raise AssertionError('duplicate accepted')
 runsql("DELETE FROM paymesh.transactions WHERE merchant_id='synthetic'")
try:
 for name,fn in [('commit-two-writes',commit),('full-rollback',rollback),('savepoint',savepoint),('failed-transaction-needs-rollback',aborted),('deferred-constraint-at-commit',deferred),('concurrent-unique-and-tenant-scope',duplicates),('reproduce-lost-update',lost_update),('optimistic-update-count',optimistic),('concurrent-refund-guard',guarded_refunds),('reproduce-write-skew',skew),('parent-lock-prevents-skew',parent_lock),('constraint-and-type-sqlstates',constraint_states),('check-allows-null-unless-not-null',null_check),('exact-decimal-and-scale-rounding',money),('default-versus-explicit-null',defaults),('instant-across-session-timezones',timezones),('restored-transactions-constraints',live_table_copy)]:test(name,fn)
finally:
 runsql('DROP SCHEMA atlas_check CASCADE')
Path(__file__).with_name('postgresql-results.json').write_text(json.dumps({'postgresql':version,'scope':'Isolated synthetic SQL tests, not application integration tests','results':results},indent=2)+'\n')
print(len(results),'checks passed')
