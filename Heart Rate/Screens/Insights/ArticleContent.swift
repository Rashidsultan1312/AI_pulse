import Foundation

// Хранилище для всего текстового контента
struct ArticleContent {
    
    static let articles: [InsightArticle] = [
        
        .init(title: "What should my heart rate be?",
              imageName: "insight_1",
              heroImageName: "insight_1", // 👈 Я исправил 'insight_1' на 'hero_1'
              articleText: """
                The heart rate measures the number of times per minute that the heart contracts or beats. For most adults, a target resting heart rate is between 60–100 beats per minute.

                A healthy heart supplies the body with just the right amount of blood at the right rate for whatever the body is doing at that time. For example, being frightened or surprised automatically releases adrenaline, a hormone, to make the heart rate faster. This prepares the body to use more oxygen and energy to escape or confront potential danger.

                A resting heart rate refers to the number of times the heart beats per minute when at rest. However, age, activity levels, physical fitness, and other factors can affect a person’s resting heart rate.
                While a normal heart rate does not guarantee that a person is free of health problems, it is a useful benchmark for identifying a range of health issues.

                The pulse is often confused with the heart rate but refers instead to how many times per minute the arteries expand and contract in response to the pumping action of the heart. The pulse rate is exactly equal to the heartbeat, as the contractions of the heart cause the increases in blood pressure in the arteries that lead to a noticeable pulse.

                Taking the pulse is, therefore, a direct measure of heart rate. It is important to identify whether a person’s heart rate sits within the normal range. If disease or injury weakens the heart, the organs will not receive enough blood to function normally.
                The heart rate gets progressively slower as a person moves through childhood toward adolescence. 

                The normal resting heart rate for adults over the age of 10 years, including older adults, is between 60–100 beats per minute (bpm).
                Highly trained athletes may have a resting heart rate below 60 bpm, sometimes reaching 40 bpm.

                The speed of the heart is not the only factor to bear in mind when considering its health. The rhythm of the heartbeat is important too. The heart should beat with a steady rhythm, and there should be a regular gap between beats.

                The muscle has an electrical system that tells it when to beat and push blood around the body. A faulty electrical system can lead to an abnormal heart rhythm, known as arrhythmia.
                It is normal for the heart rate to vary throughout the day in response to exercise, anxiety, excitement, and fear. However, a person should not normally be aware of their resting heartbeat.
                People concerned about palpitations or ectopic beats should speak to your doctor who will be able to carry out an electrocardiogram (ECG) to assess the heart rate and the rhythm.

                The type depends on where in the heart the abnormal rhythm starts, and whether it causes the heart to beat too fast or too slow.

                If a person feels that their heart is beating out of rhythm, too fast, or too slow, it is advisable to contact a doctor about these symptoms. A person may also feel the sensation of having missed or “skipped” a beat, or it may feel like there has been an extra beat.
                """,
              sourceURL: "https://www.medicalnewstoday.com/articles/235710#abnormal-heart-rhythms"),

        .init(title: "What are heart rate monitors?",
              imageName: "insight_2",
              heroImageName: "insight_2", // 👈 Исправлено
              articleText: """
                Heart rate monitors are devices that detect and measure your heart or pulse rate. Thanks to advances in technology, these devices are small, wearable and many use sensors that are very accurate. However, while these devices are excellent for personal use, they’re no substitute for medical devices that are much more accurate.

                Heart rate monitors are very popular features in wearable devices like smartwatches and fitness trackers. Many of these devices also connect wirelessly to smartphones and computers. That allows users easy access to review their heart rate data. 

                Heart rate monitors see common use for the following purposes:
                Tracking heart rate during exercise.
                Monitoring stress and activity levels during the day.
                Tracking sleep quality at night.
                Monitoring your vital signs at home, especially if you have certain health conditions or concerns.

                How do I use these devices?
                Depending on the type of device, you may need to use them differently. Some you wear around your wrist or forearm. Others are rings you wear on a finger. The chest-strap devices have their sensors in the strap. Depending on the mode, some connect with a cable or wirelessly to a device that you can clip onto your clothing or you can carry in a pocket, and many of the newer models use wireless connections to your phone or another device. 

                To learn the best way to use your device and get the most accurate results, be sure to read the instruction manual completely. Most of these devices also have websites with user forums, where you can ask questions and share information about how these devices can best help you.

                What are the risks of using heart rate monitors?
                The risks of using heart rate monitors are very minimal. For the most part, the greatest concern is an allergy you might have to some of the materials that make up the band or the device itself.
                However, just because these devices are safe to use doesn’t mean they’re a substitute for officially approved medical devices. If you have health concerns that need monitoring, the safest and most accurate devices are those that have approval from the U.S. Food & Drug Administration (or from the appropriate regulatory agency in your country). That approval means these devices meet strict quality and accuracy standards and that they're ideal for medical use.
                """,
              sourceURL: "https://my.clevelandclinic.org/health/diagnostics/23429-heart-rate-monitor"),
        
        .init(title: "The heart rate secret: from sleep and alcohol to fight or flight",
              imageName: "insight_3",
              heroImageName: "insight_3", // 👈 Исправлено
              articleText: """
                Are you sitting comfortably? If so, put out one hand so you’re looking at your palm, then use the first and middle fingers of your other hand to feel for the pulse on the inside of your wrist. Count the beats for 60 seconds, and that’s your heart rate. Assuming you’re resting rather than exercising or stressed, it will probably be somewhere between 60 and 100 beats a minute. But what does it mean if it’s at the top or bottom of the range – or even outside it?

                We’ve known about the connection between heart rate and health for thousands of years. Herophilus of Alexandria (325-255 BC), sometimes known as the father of anatomy, designed a water clock to time the pulse, at around the same time that Chinese physicians were using its strength and regularity to diagnose disease. A couple of centuries later, Roman Greek surgeon Galen nudged things along by watching recently deceased gladiators’ hearts beat their last, going on to write: “Exercise to begin with – and so long as it is practised in moderation – renders the pulse vigorous large, quick, and frequent. Large amounts of exercise, which exceed the capacity of the individual, make it small, faint, quick and extremely frequent.” Since then, physicians and scientists have been hard at work on different ways to track our heart rate, as well as the variations within it. What do the measurements actually tell us?

                Let’s go back to that resting heart-rate figure of 60-100bpm. “A healthy range can vary depending on factors like age, gender, fitness level and overall health,” says Dr David Culpepper, a family medicine specialist with LifeMD. “Athletes and people who are very fit may have resting heart rates below 60bpm, while babies and young children can often have heart rates above 100bpm, which gradually decrease as they get older.”
                If your heart rate is below 60bpm, you may now be congratulating yourself on your athlete-level fitness. But take a beat. Bradycardia – a slower-than-normal heart rate – “can also be caused by issues with the heart’s electrical system, an underactive thyroid, or other medical conditions,” says Culpepper. “Also, some medications – particularly those used to treat high blood pressure and certain heart conditions – can lower heart rate as a side-effect.”

                Your lifestyle can also affect your heart rate, usually by raising it. Stimulants can cause dramatic changes. “Caffeine increases the effects of adrenaline on the heart, which means that excessive consumption of tea, coffee, or energy drinks can cause a temporary increase in heart rate – though this effect may decrease over time as your tolerance increases,” says Dr Elijah Behr, a consultant cardiologist at London’s Mayo Clinic. “Nicotine in cigarettes can temporarily increase heart rate and, with prolonged use, contribute to chronic heart and circulatory issues. Alcohol, depending on the individual and the amount consumed, can either increase or decrease the heart rate.” Over the longer term, too much booze can affect the heart muscle, impacting on the heart rate and overall cardiac health.

                Emotional states such as stress, anxiety or excitement can cause short-term spikes in heart rate, and chronic stress might contribute to long-term irregularities. But if you’re not under any particular pressure, a fast-beating heart is cause for concern. “If it comes out of the blue, with no apparent reason, then it can be due to an underlying heart condition, and needs to be investigated,” says Behr. “Obviously, the urgency is greater if the heart racing causes dizziness or a blackout.”

                What about exercise? As Galen noticed, while you’re actually exercising, your heart rate will increase as your heart pumps blood to your muscles and lungs. A recent meta-analysis of studies confirms that cardiovascular exercise (and yoga) can lower your resting heart rate over time – but there also seem to be benefits to the heart’s health from strength training, though the mechanism is less well understood. Even more relaxed forms of exercise, such as tai chi and qigong, might help.

                You may have come across the “finite heartbeat theory”, or the idea that there is a limit to how many times our ticker can tock over our lives, but it’s unlikely to be worth worrying about this: even if it was true that you only had four billion or so beats to play with, the (relatively) small amount of time your heart rate is elevated by exercise should be more than balanced out by it lowering over time.
                """,
              sourceURL: "https://www.theguardian.com/lifeandstyle/2024/jan/22/the-heart-rate-secret-what-it-reveals-about-our-health-from-sleep-and-alcohol-to-fight-or-flight"),
        
        .init(title: "How Nutrition Affects the Heart?",
              imageName: "insight_4",
              heroImageName: "insight_4", // 👈 Исправлено
              articleText: """
                Your heart rate responds, for better or worse, to the quality of the foods you consume over time. Do certain foods elevate your heart rate too much? Can other foods lower heart rate immediately?

                Bad for Heart Rate
                Avoid these foods known to elevate the heart rate:
                Fried foods
                Caffeine
                Alcohol
                High-sodium foods
                Processed packaged foods
                Many restaurant foods
                Foods high in tyramine, an amino acid

                In particular, a combination of salt and tyramine can harm the heart in excessive amounts.
                Also, watch the quantity of food you eat. A large meal can temporarily increase your heart rate as your body works to move blood from the heart to the digestive system.

                Good for Heart Rate
                So, are there foods to lower heart rate immediately? Sorry — there’s no superfood that will quickly drop an elevated heart rate. But over time, certain nutritious foods can lower your heart rate and keep your heart healthy, including:
                Healthy fats: These fats play a crucial role in the body’s energy production, nutrient absorption, cell function, and hormone production:
                Foods high in potassium: Potassium and sodium are both electrolytes — minerals that must stay balanced within the body. Potassium counteracts sodium’s effect on your blood pressure and helps regulate your heart rate. 

                Other Causes of High Heart Rate
                Of course, there are other factors beyond diet that may contribute to elevated heart rate, including but not limited to:
                Stress and anxiety
                Dehydration
                Illness
                Smoking
                Strenuous exercise
                Poor sleep habits
                Certain medications with stimulants, like over-the-counter cold medicine with pseudoephedrine

                Foster a Healthy Heart Rate
                Take a few deep breaths and have that banana after the race, perhaps with some peanut butter. It may not immediately drop your heart rate, but it’s a balanced, potassium-rich snack. And be sure to drink plenty of water to restore your healthy hydration levels.
                In fact, get in the habit of hydrating well and including the nutritious foods we’ve listed in your go-to snacks and meals. They’ll help regulate your heart over time.
                If you often experience a high heart rate, finding the root cause and addressing it are both essential to your health.sThe Signature Healthcare family can explore why your heart races and help you find a balanced nutrition plan that encourages a healthy heart rate. 
                """,
              sourceURL: "https://signaturehealthcare.org/foods-to-lower-heart-rate-immediately/"),
        
        .init(title: "Heart rate training zones explained",
              imageName: "insight_5",
              heroImageName: "insight_5", // 👈 Исправлено
              articleText: """
                As we know, running is an aerobic exercise which promotes and improves cardiovascular health and endurance. Indeed, running – along with cycling, swimming and cross-country skiing – is right at the top of the list of the very best forms of aerobic exercise. These sports are often referred to as ‘pure’ aerobic activities.

                Aerobic literally means ‘with oxygen’ and refers to sports and exercises that require oxygen to be spread around the body as quickly as possible to fuel the muscles. The oxygen is moved via the blood and therefore your heart rate quickens and quickens to pump this fuel to the muscles working hard during the activity. As a result, regularly increasing your heart rate through exercise will strengthen your heart and reduce your chances of having any health problems in that area, as well as improving lung health and capacity.

                Heart training zones, or target heart rate training zones, is the bpm you are aiming to reach while training. According to the British Heart Foundation, this shouldn’t exceed 70% of your maximum heart rate. 

                You can calculate your maximum heart rate by subtracting your age from 220. 

                So for example, I’m 39 years old. 220 - 39 = 181. My maximum heart rate is 181bpm. 

                Therefore, according to the BHF my target heart rate training zone should be 70% of 181. Do you remember how to do maths? I don’t. So I simply type into Google ‘what is 70% of 181?’ and Google tells me that it is 127.6. And I can stop sweating, thanks Google!

                As a result of this rather shameful mathematics, I am now aware that when I go out running, cycling or exercising, I should be aiming to train at 127bpm and not more. However, I could and probably would train at 115-120bpm to stay cautious and also give my heart a solid workout.
                Of course, this is where a fitness watch comes in extremely useful as you don’t want to be counting your heart rate via the pulse on your wrist while running, although it is possible. 
                Having a fitness watch will simplify this as well as make you aware when you’re pushing yourself too hard or not hard enough.

                Steps to measure your heart rate training zone:
                Calculate your maximum heart rate: (220 - your age = maximum heart rate)
                Calculate 70% of your maximum heart rate: ask Google
                Consider subtracting 10 to 15 from this if you’re a beginner
                Use a fitness watch to monitor your heart rate while exercising
                Once you are comfortable and confident with training at this level, and are feeling ready to push harder to promote heart health and stamina, you can start mixing up heart rate training zones. 

                What are the heart rate training zones? 
                Zone 1       - very light     - 50 to 60% Max Heart Rate
                Zone 2       -s_light             - 60 to 70% MHR
                Zone 3       - moderate    - 70 to 80% MHR
                Zone 4       - hard            - 80 to 90% MHR
                Zone 5       -s_maximum    - 90 to 100% MHR

                Heart rate training zones are a great way for beginners to improve their fitness without running into trouble. However, for more experienced runners, heart rate training should be incorporated into your training schedule to monitor and improve cardiovascular health and endurance for upcoming races or long-distance challenges. 
                """,
              sourceURL: "https://styrkr.com/blogs/training-and-nutrition-hub/heart-rate-zone-training")
    ]
}
