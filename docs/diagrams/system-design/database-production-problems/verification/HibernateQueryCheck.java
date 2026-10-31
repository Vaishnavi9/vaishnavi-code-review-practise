import jakarta.persistence.*;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/** Standalone synthetic fixture. No application entities, credentials, or live DB. */
public class HibernateQueryCheck {
    @Entity(name="AtlasMerchant")
    @Table(name="atlas_merchant")
    public static class Merchant {
        @Id Long id;
        String name;
        public Merchant() {}
        Merchant(long id, String name) { this.id=id; this.name=name; }
        public String getName() { return name; }
    }
    @Entity(name="AtlasPayment")
    @Table(name="atlas_payment")
    public static class Payment {
        @Id Long id;
        @ManyToOne(fetch=FetchType.LAZY, optional=false)
        Merchant merchant;
        public Payment() {}
        Payment(long id, Merchant merchant) { this.id=id; this.merchant=merchant; }
        public Merchant getMerchant() { return merchant; }
    }
    static void check(boolean value, String message) {
        if (!value) throw new AssertionError(message);
    }
    public static void main(String[] args) {
        Configuration config=new Configuration().addAnnotatedClass(Merchant.class).addAnnotatedClass(Payment.class);
        config.setProperty("hibernate.connection.url","jdbc:h2:mem:atlas_query_check;DB_CLOSE_DELAY=-1");
        config.setProperty("hibernate.connection.driver_class","org.h2.Driver");
        config.setProperty("hibernate.hbm2ddl.auto","create-drop");
        config.setProperty("hibernate.generate_statistics","true");
        config.setProperty("hibernate.cache.use_second_level_cache","false");
        config.setProperty("hibernate.cache.use_query_cache","false");
        try (SessionFactory sf=config.buildSessionFactory()) {
            try (Session s=sf.openSession()) {
                var tx=s.beginTransaction();
                for (long i=1;i<=3;i++) { Merchant m=new Merchant(i,"M"+i);s.persist(m);s.persist(new Payment(i,m)); }
                tx.commit();
            }
            sf.getStatistics().clear();
            List<String> lazyNames;
            try (Session s=sf.openSession()) {
                var tx=s.beginTransaction();
                lazyNames=s.createQuery("select p from AtlasPayment p order by p.id",Payment.class)
                    .setMaxResults(3).getResultList().stream().map(p->p.getMerchant().getName()).toList();
                tx.commit();
            }
            long lazy=sf.getStatistics().getPrepareStatementCount();
            sf.getStatistics().clear();
            List<String> fetchedNames;
            try (Session s=sf.openSession()) {
                var tx=s.beginTransaction();
                fetchedNames=s.createQuery("select p from AtlasPayment p join fetch p.merchant order by p.id",Payment.class)
                    .setMaxResults(3).getResultList().stream().map(p->p.getMerchant().getName()).toList();
                tx.commit();
            }
            long fetched=sf.getStatistics().getPrepareStatementCount();
            check(lazy==4,"Expected 4 prepared SELECTs, got "+lazy);
            check(fetched==1,"Expected 1 prepared SELECT, got "+fetched);
            check(lazyNames.equals(fetchedNames),"Outputs differ");
            System.out.println("PASS N+1 cold contexts: "+lazy+" SELECTs versus "+fetched+"; same results");
            try (Session s=sf.openSession()) {
                var tx=s.beginTransaction();Merchant m=s.find(Merchant.class,1L);m.name="changed";s.flush();
                check(s.contains(m),"flush should not detach entity");tx.rollback();
            }
            try (Session s=sf.openSession()) { check(s.find(Merchant.class,1L).getName().equals("M1"),"Flushed change survived rollback"); }
            System.out.println("PASS flush keeps managed state; subsequent rollback discards SQL changes");
            Merchant detached=new Merchant(1L,"merged");
            try (Session s=sf.openSession()) {
                var tx=s.beginTransaction();Merchant managed=s.merge(detached);
                check(managed!=detached && s.contains(managed) && !s.contains(detached),"merge ownership mismatch");tx.rollback();
            }
            System.out.println("PASS merge returns managed copy; input stays detached");
        }
        check(new BigDecimal("0.29").setScale(2,RoundingMode.UNNECESSARY).movePointRight(2).longValueExact()==29,"money conversion");
        try {new BigDecimal("0.291").setScale(2,RoundingMode.UNNECESSARY);throw new AssertionError("precision accepted");} catch(ArithmeticException expected) {}
        try {new BigDecimal("9223372036854775808").longValueExact();throw new AssertionError("overflow accepted");} catch(ArithmeticException expected) {}
        System.out.println("PASS exact decimal conversion; excess precision and overflow rejected");
    }
}
