//TO DO: add the entitlement ID from the RevenueCat dashboard that is activated upon successful in-app purchase for the duration of the purchase.
const entitlementID = 'TSPプレミアムプラン';

//TO DO: add your subscription terms and conditions
const footerText =
"""Don't forget to add your subscription terms and conditions. 

Read more about this here: https://www.revenuecat.com/blog/schedule-2-section-3-8-b""";

//TO DO: add the Apple API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
//課金機能(Revenucat)
// const appleApiKey = 'appl_FqFukGrTjwGVYwYkalAgeTGGkog'; // 本番
const appleApiKey = 'appl_zpRHoKSWQoxVqMeERkTqKTnykfP'; //開発

//TO DO: add the Google API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const googleApiKey = 'googl_api_key';

//TO DO: add the Amazon API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const amazonApiKey = 'amazon_api_key';

//サーバーKEY(cloudMessage)
// const serverKey =
//     'AAAAsjXnpKQ:APA91bGhkNiydAXPg6rWfkGVXyOC7TQXuTJs0DrXJUXjTbuFvDf12cctlJb4lLh2BOeiJDBUu7zKe5VsVUDvnSsqU5O0b22OTJoJvdN6A-9LxNjXnXCnPAsda4kSI9aunT6dBlQ5az-e';//本番
const serverKey =
    'AAAAsjXnpKQ:APA91bGhkNiydAXPg6rWfkGVXyOC7TQXuTJs0DrXJUXjTbuFvDf12cctlJb4lLh2BOeiJDBUu7zKe5VsVUDvnSsqU5O0b22OTJoJvdN6A-9LxNjXnXCnPAsda4kSI9aunT6dBlQ5az-e';//本番
// const fcmUrl = 'https://fcm.googleapis.com/v1/projects/tsuyosuketeniss/messages:send'; //本番
const fcmUrl = 'https://fcm.googleapis.com/v1/projects/tsuyosuketest/messages:send'; //開発
