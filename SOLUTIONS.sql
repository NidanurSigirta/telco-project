-- SORU 1.1: 'Kobiye Destek' tarifesine abone olan müşterileri listele
-- CUSTOMERS tablosu müşteri bilgilerini, TARIFFS tablosu ise tarife detaylarını tutuyor.
-- Bu sorguda iki tabloyu TARIFF_ID üzerinden JOIN yaparak hangi müşterinin hangi tarifede olduğunu tespit ediyoruz.
-- TARIFFS tablosundan 'Kobiye Destek' adlı tarifenin ID'sini bulup, bu ID'ye sahip müşterileri filtreler.
-- WHERE koşulunda tarife adını 'Kobiye Destek' olarak filtreleyerek yalnızca bu tarifedeki müşterileri listeliyoruz.
-- JOIN kullanmak, tarife adını direkt sorguda kullanmamızı sağlar; ID'yi ezberlemek gerekmez.
-- Sonuçta müşteri ID, isim, şehir, kayıt tarihi ve tarife adı kolonları gösteriliyor.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY,
    C.SIGNUP_DATE,
    T.NAME AS TARIFF_NAME
FROM CUSTOMERS C
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
WHERE T.NAME = 'Kobiye Destek';



-- SORU 1.2: 'Kobiye Destek' tarifesine abone olan en yeni müşteriyi bul
-- En yeni müşteriyi bulmak için SIGNUP_DATE kolonunu kullanıyoruz.
-- SIGNUP_DATE kolonu VARCHAR2 tipinde saklandığından karşılaştırma yapabilmek için TO_DATE fonksiyonuyla DATE tipine dönüştürüyoruz.
-- İç sorguda (subquery) Kobiye Destek tarifesindeki müşteriler arasından en yeni kayıt tarihi olan tek müşteriyi döndürmek için MAX(SIGNUP_DATE) kullanıyoruz.
-- Dış sorguda bu maksimum tarihe eşit kayıt tarihine sahip müşterileri listeliyoruz; aynı tarihte birden fazla kayıt varsa hepsi görünür.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY,
    C.SIGNUP_DATE,
    T.NAME AS TARIFF_NAME
FROM CUSTOMERS C
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
WHERE T.NAME = 'Kobiye Destek'
AND TO_DATE(C.SIGNUP_DATE, 'DD/MM/YYYY') = (
    SELECT MAX(TO_DATE(C2.SIGNUP_DATE, 'DD/MM/YYYY'))
    FROM CUSTOMERS C2
    JOIN TARIFFS T2 ON C2.TARIFF_ID = T2.TARIFF_ID
    WHERE T2.NAME = 'Kobiye Destek'
);



-- SORU 2.1: Müşteriler arasında tarifelerin dağılımını bul
-- Bu sorgu her tarifenin kaç müşteriye sahip olduğunu hesaplar.
-- CUSTOMERS ve TARIFFS tablolarını JOIN'leyerek her müşterinin tarife adına ulaşıyoruz.
-- GROUP BY ile tarife bazında gruplama yapılır, COUNT ile müşteri sayısı bulunur.
-- ORDER BY DESC ile en fazla müşteriye sahip tarife en üstte görüntüleniyor; bu sayede hangi tarifeye talebin yüksek olduğu hızlıca anlaşılır.

SELECT 
    T.NAME AS TARIFF_NAME,
    COUNT(C.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM CUSTOMERS C
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
GROUP BY T.NAME
ORDER BY CUSTOMER_COUNT DESC;


-- SORU 3.1: Kayıt olan en eski müşterileri belirle
-- En eski müşterileri bulmak için SIGNUP_DATE kolonunu TO_DATE ile DATE tipine çevirip MIN fonksiyonu kullanıyoruz.
-- Proje açıklamasında belirtildiği gibi en eski müşterilerin CUSTOMER_ID değeri mutlaka en küçük olmayabilir; bu nedenle ID'ye göre değil tarihe göre filtreleme yapıyoruz.
-- Subquery ile tüm müşteriler arasındaki en küçük kayıt tarihini bulup, dış sorguda bu tarihe eşit olan tüm müşterileri listeliyoruz.
-- Aynı gün kaydolan birden fazla müşteri olabileceğinden sonuç tek satır olmayabilir; bu durumda hepsi listelenecektir.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY,
    C.SIGNUP_DATE
FROM CUSTOMERS C
WHERE TO_DATE(C.SIGNUP_DATE, 'DD/MM/YYYY') = (
    SELECT MIN(TO_DATE(SIGNUP_DATE, 'DD/MM/YYYY'))
    FROM CUSTOMERS
)
ORDER BY C.CUSTOMER_ID;


-- SORU 3.2: En eski kayıt tarihine sahip müşterilerin şehirlere göre dağılımı
-- Bir önceki sorguda tespit ettiğimiz en eski kayıt tarihindeki müşterilerin hangi şehirlerden geldiğine bakıyoruz
-- GROUP BY ile şehir bazında gruplama yapıyoruz.
-- COUNT ile her şehirdeki müşteri sayısını hesaplayıp ORDER BY DESC ile en fazla müşteri bulunan şehri en üste taşıyoruz.
-- ORDER BY ile en fazla müşterisi olan şehir en üstte gösterilir.

SELECT 
    C.CITY,
    COUNT(C.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM CUSTOMERS C
WHERE TO_DATE(C.SIGNUP_DATE, 'DD/MM/YYYY') = (
    SELECT MIN(TO_DATE(SIGNUP_DATE, 'DD/MM/YYYY'))
    FROM CUSTOMERS
)
GROUP BY C.CITY
ORDER BY CUSTOMER_COUNT DESC;


-- SORU 4.1: Aylık kaydı eksik olan müşterilerin ID'lerini bul
-- CUSTOMERS tablosunda 10.000 müşteri bulunurken MONTHLY_STATS tablosuna ekleme sırasında hata oluşmuş ve bazı müşterilerin aylık kayıtları sisteme girmemiş.
-- Bu eksikliği tespit etmek için LEFT JOIN kullanıyoruz; LEFT JOIN tüm müşterileri getirir, MONTHLY_STATS'ta eşleşmeyenlerde sağ taraf NULL olur.
-- Böylece LEFT JOIN ile tüm müşterileri alıyor, MONTHLY_STATS'ta karşılığı olmayanları filtreliyoruz.
-- WHERE MS.CUSTOMER_ID IS NULL koşuluyla yalnızca aylık istatistik kaydı bulunmayan müşterileri buluyoruz.
-- Sonuçta 50 müşterinin kaydının eksik olduğu görülmektedir; bu müşterilerin fatura süreçleri kontrol edilmelidir.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY
FROM CUSTOMERS C
LEFT JOIN MONTHLY_STATS MS ON C.CUSTOMER_ID = MS.CUSTOMER_ID
WHERE MS.CUSTOMER_ID IS NULL
ORDER BY C.CUSTOMER_ID;

-- SORU 4.2: Aylık kaydı eksik olan müşterilerin şehirlere göre dağılımı
-- Aylık kaydı eksik olan 50 müşterinin hangi şehirlerde yoğunlaştığını anlamak için şehir bazında gruplama yapıyoruz.
-- Yine LEFT JOIN ve IS NULL kombinasyonuyla eksik kayıtlı müşterileri seçip GROUP BY CITY ile şehir bazında sayıyoruz.
-- Bu analiz hangi şehirlerde veri eksikliği yaşandığını gösterir ve operasyonel sorunları tespit etmeye yardımcı olur.
-- Osmaniye 3 kayıpla en fazla etkilenen şehir olarak öne çıkmaktadır.

SELECT 
    C.CITY,
    COUNT(C.CUSTOMER_ID) AS MISSING_COUNT
FROM CUSTOMERS C
LEFT JOIN MONTHLY_STATS MS ON C.CUSTOMER_ID = MS.CUSTOMER_ID
WHERE MS.CUSTOMER_ID IS NULL
GROUP BY C.CITY
ORDER BY MISSING_COUNT DESC;


-- SORU 5.1: Veri limitinin en az %75'ini kullanan müşterileri bul
-- Veri kullanım oranını hesaplamak için DATA_USAGE değerini DATA_LIMIT'e bölüp 100 ile çarpıyoruz.
-- DATA_LIMIT değeri 0 olan tarifeler (örneğin Kurumsal SMS) bu hesaplamaya dahil edilmiyor; sıfıra bölme hatasını önlemek için WHERE T.DATA_LIMIT > 0 koşulu ekliyoruz.
-- Kullanım oranı 0.75 veya üzeri olan müşteriler listelenir, yüzde olarak göstermek için 100 ile çarpıyoruz.
-- Bu sorgu şirketin veri kapasitesi dolmak üzere olan müşterileri önceden tespit edip paket yükseltme teklifinde bulunmasına olanak sağlar.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY,
    T.NAME AS TARIFF_NAME,
    T.DATA_LIMIT,
    MS.DATA_USAGE,
    ROUND((MS.DATA_USAGE / T.DATA_LIMIT) * 100, 2) AS USAGE_PERCENT
FROM CUSTOMERS C
JOIN MONTHLY_STATS MS ON C.CUSTOMER_ID = MS.CUSTOMER_ID
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
WHERE T.DATA_LIMIT > 0
AND (MS.DATA_USAGE / T.DATA_LIMIT) >= 0.75
ORDER BY USAGE_PERCENT DESC;


-- SORU 5.2: Veri, dakika ve SMS limitlerinin tamamını tüketen müşterileri bul
-- Üç limitin de (DATA, MINUTE, SMS) tamamen tüketilmiş olması gerektiğinden üç koşulu AND ile birleştiriyoruz.
-- DATA_LIMIT 0 olan tarifelerde veri kullanımı zaten 0 olacağından bu tarifeleri DATA kontrolünden hariç tutuyoruz.
-- Mevcut veri setinde hiçbir müşteri üç limiti birden tam olarak tüketmediğinden sorgu 0 satır döndürmektedir; bu veri setinin özelliğinden kaynaklanmakta olup sorgu mantığı doğrudur.
-- Benzer şekilde MINUTE_LIMIT ve SMS_LIMIT 0 olan durumlarda ilgili kullanım kontrolü atlanır.
-- Gerçek ortamda bu sorgu kapasitesini aşan müşterileri tespit edip ek ücretlendirme veya paket yükseltme süreçlerini tetiklemek için kullanılabilir.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY,
    T.NAME AS TARIFF_NAME,
    MS.DATA_USAGE,
    MS.MINUTE_USAGE,
    MS.SMS_USAGE
FROM CUSTOMERS C
JOIN MONTHLY_STATS MS ON C.CUSTOMER_ID = MS.CUSTOMER_ID
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
WHERE (T.DATA_LIMIT = 0 OR MS.DATA_USAGE >= T.DATA_LIMIT)
AND (T.MINUTE_LIMIT = 0 OR MS.MINUTE_USAGE >= T.MINUTE_LIMIT)
AND (T.SMS_LIMIT = 0 OR MS.SMS_USAGE >= T.SMS_LIMIT)
ORDER BY C.CUSTOMER_ID;

-- Kontrol: Veri kullanımı limit eşit veya üzeri olan kaç müşteri var?
SELECT COUNT(*) FROM MONTHLY_STATS MS
JOIN TARIFFS T ON (SELECT TARIFF_ID FROM CUSTOMERS WHERE CUSTOMER_ID = MS.CUSTOMER_ID) = T.TARIFF_ID
WHERE T.DATA_LIMIT > 0 AND MS.DATA_USAGE >= T.DATA_LIMIT;


-- SORU 6.1: Ödenmemiş ücreti olan müşterileri bul
-- MONTHLY_STATS tablosundaki PAYMENT_STATUS kolonu her müşterinin bu ayki ödeme durumunu PAID, UNPAID veya LATE olarak tutar.
-- 'UNPAID' değerine sahip kayıtları filtreleyerek ödenmemiş ücreti olan müşterileri listeliyoruz.
-- CUSTOMERS ve TARIFFS tablolarını JOIN'leyerek müşterinin adı, şehri, tarifesi ve aylık ücreti de sonuca ekliyoruz.
-- Bu liste tahsilat ekibinin öncelikli olarak iletişime geçmesi gereken müşterileri belirlemek için kullanılabilir.

SELECT 
    C.CUSTOMER_ID,
    C.NAME,
    C.CITY,
    T.NAME AS TARIFF_NAME,
    T.MONTHLY_FEE,
    MS.PAYMENT_STATUS
FROM CUSTOMERS C
JOIN MONTHLY_STATS MS ON C.CUSTOMER_ID = MS.CUSTOMER_ID
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
WHERE MS.PAYMENT_STATUS = 'UNPAID'
ORDER BY C.CUSTOMER_ID;


-- SORU 6.2: Tüm ödeme durumlarının farklı tarifeler genelindeki dağılımı
-- Her tarifede kaç müşterinin PAID, UNPAID ve LATE durumunda olduğunu görmek için tarife adı ve ödeme durumunu birlikte grupluyoruz.
-- MONTHLY_STATS, CUSTOMERS ve TARIFFS tablolarını JOIN'leyerek tarife adlarına ulaşıp GROUP BY ile iki kolonlu gruplama yapıyoruz.
-- COUNT(*) ile her tarife-ödeme durumu kombinasyonundaki kayıt sayısını hesaplıyoruz; ORDER BY ile sonuçlar tarife adına göre alfabetik sıralanıyor.
-- Bu analiz hangi tarifede ödeme sorunlarının daha yaygın olduğunu ortaya koyar ve şirketin fiyatlandırma veya müşteri segmentasyonu stratejisini değerlendirmesine yardımcı olur.

SELECT 
    T.NAME AS TARIFF_NAME,
    MS.PAYMENT_STATUS,
    COUNT(*) AS COUNT
FROM MONTHLY_STATS MS
JOIN CUSTOMERS C ON MS.CUSTOMER_ID = C.CUSTOMER_ID
JOIN TARIFFS T ON C.TARIFF_ID = T.TARIFF_ID
GROUP BY T.NAME, MS.PAYMENT_STATUS
ORDER BY T.NAME, MS.PAYMENT_STATUS;






