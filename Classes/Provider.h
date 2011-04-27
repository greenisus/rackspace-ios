//
//  Provider.h
//  OpenStack
//
//  Created by Mike Mayo on 9/30/10.
//  The OpenStack project is provided under the Apache 2.0 license.
//

#import <Foundation/Foundation.h>


@interface Provider : NSObject <NSCoding> {
    
/*    
    { 
      "name": "Rackspace Cloud (US)", "auth_endpoint_url": "https://auth.api.rackspacecloud.com/v1.0",
      "rss_feeds": [
        { "name": "Cloud Servers Status", "url": "http://whatever" },
        { "name": "Cloud Files Status", "url": "http://whatever" },
        { "name": "Cloud Sites Status", "url": "http://whatever" },
        { "name": "Rackspace Cloud Blog", "url": "http://whatever" }
      ],
      "contact_urls": [
        { "name": "US Phone Support", "url": "tel://8001112222" }
      ],
      "bar_style": "black",
      "logos": {
        "landscape_logo": "url to 279x62 logo",
        "landscape_logo_2x": "url to 558x124 logo",
        "provider_icon": "url to 35x35 logo",
        "provider_icon_2x": "url to 70x70 logo",
        "provider_icon_72": "url to 72x72 logo",
        "provider_large": "url to 1000x1000 logo",
        "compute_icon": "35x35 compute logo",
        "compute_icon_2x": "70x70 compute logo",
        "compute_logo": "1000x1000 compute logo",
        "storage_icon": "35x35 storage logo",
        "storage_icon_2x": "70x70 storage logo",
        "storage_logo": "1000x1000 storage logo",
      }
*/

    // navigation bar style
    UIBarStyle *barStyle;
    UIColor *tintColor;
    BOOL barTranslucent;

    // the name of the provider (example: Rackspace Cloud)
    NSString *name;
    
    // endpoint for authentication (example: https://auth.api.rackspacecloud.com/v1.0)
    NSURL *authEndpointURL;
    
    // URLs to RSS feeds, typically for system statuses, but it could be anything
    NSArray *rssFeeds;
    
    // URLs to ways to contact the provider.  Can be any type of URL.  In the app,
    // touching will open the URL if the device supports it.
    // Examples:
    //      http://support.rackspacecloud.com
    //      tel://8005557777
    //      sms://8005557777
    //      mailto:support@rackspacecloud
    //      maps://string-that-works-with-google-maps
    NSArray *contactURLs;
    
    // Dictionary of logos.  All logos should be PNG with transparent backgrounds.
    // Should follow this format ("key": "value"):
    //      "provider_icon":    "url to 35x35 logo"         <-- sort of required
    //      "provider_icon_2x": "url to 70x70 logo"         <-- sort of required
    //      "provider_large":   "url to 1000x1000 logo"     <-- sort of required
    //      "compute_icon":     "35x35 compute logo"
    //      "compute_icon_2x":  "70x70 compute logo"
    //      "compute_logo":     "1000x1000 compute logo"
    //      "storage_icon":     "35x35 storage logo"
    //      "storage_icon_2x":  "70x70 storage logo"
    //      "storage_logo":     "1000x1000 storage logo"
    // 
    // If no provider* logos are provided, the OpenStack logo will be used where
    // a provider's logo should appear.
    // Compute and storage logos are used in their respective sections in the app.
    // If they are not present, the provider logo will be used, and if the provider
    // logo is not present, the OpenStack logo will be used.
    // If the logo value is not a URL, it should be included in this application's
    // resource bundle
    NSDictionary *logoURLs;
    
    // UIImage objects serialized after the images are loaded from URLs
    NSDictionary *logoObjects;
    
    NSString *authHelpMessage;
}

+ (NSArray *)providers;
+ (Provider *)fromJSON:(NSDictionary *)dict;
- (BOOL)isRackspace;

@property (retain) NSString *name;
@property (retain) NSURL *authEndpointURL;
@property (retain) NSString *authHelpMessage;
@property (retain) NSArray *rssFeeds;
@property (retain) NSArray *contactURLs;
@property (retain) NSDictionary *logoURLs;
@property (retain) NSDictionary *logoObjects;

@end
