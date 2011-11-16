//
//  Foursquare2.m
//  CompanyMap
//
//  Created by  on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Foursquare2.h"

//NSString* kFSApiBaseURL                 = @"https://api.foursquare.com/v2/";
//NSString* kFSBaseURL                    = @"https://foursquare.com";
NSString* kFSAccessToken                = @"access_token";
//NSString* kFSAuthorizationCode          = @"authorization_code";
//NSString* kFSGrantType                  = @"grant_type";
//NSString* kFSRedirectUri                = @"redirect_uri";
//NSString* kFSMethodTypeAccessToken      = @"oauth2/access_token";

@interface Foursquare2 (PrivateMethods)
+ (void)get:(NSString*)methodName
 withParams:(NSDictionary*)params
   callback:(Foursquare2Callback)callback;

+ (void)post:(NSString*)methodName
  withParams:(NSDictionary*)params
    callback:(Foursquare2Callback)callback;

+ (void)request:(NSString*)methodName
     withParams:(NSDictionary*)params
     httpMethod:(NSString*)httpMethod
       callback:(Foursquare2Callback)callback;

+ (void)uploadPhoto:(NSString*)methodName
         withParams:(NSDictionary*)params
#ifdef __MAX_OS_X_VERSION_MAX_ALLOWD
          withImage:(NSImage*)image
#else
          withImage:(UIImage*)image
#endif
           callback:(Foursquare2Callback)callback;

+ (void)setAccessToken:(NSString *)token; // ヘッダーファイルに定義済み
+ (NSString*)problemTypeToString:(FoursquareProblemType)problem;
+ (NSString*)broadcastTypeToString:(FoursquareBroadcastType)broadcast;
+ (NSString*)sortTypeToString:(FoursquareSortingType)type;
// Declared in HRRestModel
+ (void)setAttributeValue:(id)attribute forKey:(NSString*)key;
+ (NSMutableDictionary*)classAttributes;
@end

@implementation Foursquare2

+ (void)initialize
{
    [self setFormat:HRDataFormatJSON];
    [self setDelegate:self];
    [self setBaseURL:[NSURL URLWithString:@"https://api.foursquare.com/v2/"]];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:kFSAccessToken] != nil) {
        [[self classAttributes] setObject:[userDefault objectForKey:kFSAccessToken] forKey:kFSAccessToken];
    }
}

+ (void)getAccessTokenForCode:(NSString *)code callback:(id)callback
{
    [self setBaseURL:[NSURL URLWithString:@"https://foursquare.com"]];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:code forKey:@"code"];
    [params setObject:@"authorization_code" forKey:@"grant_type"];
    [params setObject:REDIRECT_URL forKey:@"redirect_uri"];
    [self get:@"oauth2/access_token" withParams:params callback:callback];
}

+ (void)setAccessToken:(NSString *)token
{
    [[self classAttributes] setObject:token forKey:kFSAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kFSAccessToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeAccessToken
{
    [[self classAttributes] removeObjectForKey:kFSAccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFSAccessToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isNeedToAuthorize
{
    return ([[self classAttributes] objectForKey:kFSAccessToken] == nil);
}

+ (NSString*)stringFromArray:(NSArray*)array
{
    NSMutableString* string = [NSMutableString string];
    if ([array count] != 0) {
        for (NSString* p in array) {
            [string appendFormat:@"%@", p];
            
            if (p != [array lastObject]) {
                [string appendString:@","];
            }
        }
    }
    return string;
}

#pragma mark -
#pragma mark Users

+ (void)getDetailForUser:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"user/%@", userID];
    [self get:path withParams:nil callback:callback];
}

+ (void)searchUserPhone:(NSArray *)phones
                  email:(NSArray *)emails
                twitter:(NSArray *)twitters
          twitterSource:(NSString *)twitterSource
            facebookIDs:(NSArray *)facebookID
                   name:(NSString *)name
               callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[self stringFromArray:phones] forKey:@"phone"];
    [params setObject:[self stringFromArray:emails] forKey:@"email"];
    [params setObject:[self stringFromArray:twitters] forKey:@"twitter"];
    if (twitterSource) {
        [params setObject:twitterSource forKey:@"twitterSource"];
    }
    [params setObject:[self stringFromArray:facebookID] forKey:@"fbid"];
    if (name) {
        [params setObject:name forKey:@"name"];
    }
    [self get:@"users/search" withParams:params callback:callback];
}

/// friendの承認をまだ行っていないユーザーの一覧を取得します。
+ (void)getFriendRequestCallback:(Foursquare2Callback)callback
{
    [self get:@"users/requests" withParams:nil callback:callback];
}

#pragma mark Aspects

/// 指定したユーザーのバッジの一覧を取得します
+ (void)getBadgesForUser:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/badges", userID];
    [self get:path withParams:nil callback:callback];
}

/// 指定したユーザーチェックインの履歴を取得します
+ (void)getCheckinsByUser:(NSString *)userID
                    limit:(NSString *)limit
                   offset:(NSString *)offset
           afterTimestamp:(NSString *)afterTimestamp
          beforeTimestamp:(NSString *)beforeTimestamp
                 callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSDictionary dictionary];
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    if (offset) {
        [params setObject:offset forKey:@"offset"];
    }
    if (afterTimestamp) {
        [params setObject:beforeTimestamp forKey:@"afterTimestamp"];
    }
    if (beforeTimestamp) {
        [params setObject:beforeTimestamp forKey:@"beforeTimestamp"];
    }
    NSString* path = [NSString stringWithFormat:@"users/%@/checkins", userID];
    [self get:path withParams:params callback:callback];
}

/// 指定したユーザーのfrinedの一覧を取得します。
+ (void)getFriendsOfUser:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/friends", userID];
    [self get:path withParams:nil callback:callback];
}

/// 指定したユーザーのtipsの一覧を取得します
+ (void)getTipsFromUser:(NSString *)userID
                   sort:(FoursquareSortingType)sort
               latitude:(NSString *)latitude
              longitude:(NSString *)longitude
               callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (sort) {
        [params setObject:[self sortTypeToString:sort] forKey:@"sort"];
    }
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    NSString* path = [NSString stringWithFormat:@"users/%@/tips", userID];
    [self get:path withParams:params callback:callback];
}

/// 指定したユーザーのTODOの一覧を取得します。※ recent 以外を指定する場合は、llの指定が必要です
+ (void)getTodosFromUser:(NSString *)userID
                    sort:(FoursquareSortingType)sort
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
                callback:(Foursquare2Callback)callback
{
    if (sort == sortNearby) {
        callback(NO, @"sort is one of recent or popular.  Nearby requires geolat and geolong to be provided.");
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (sort) {
        [params setObject:sort forKey:@"sort"];
    }
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    NSString* path = [NSString stringWithFormat:@"users/%@/todos", userID];
    [self get:path withParams:params callback:callback];
}

/// 指定したユーザーが訪問したvenueの一覧を取得します。
+ (void)getVenuesVisitedByUser:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/venuehistory", userID];
    [self get:path withParams:nil callback:callback];
}

#pragma mark Actions

/// 指定したユーザーにfriendの申請を送ります。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)sendFriendRequestToUser:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/request", userID];
    [self post:path withParams:nil callback:callback];
}

/// 指定したユーザーのfriendを解除します。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)removeFriend:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/unfriend", userID];
    [self post:path withParams:nil callback:callback];
}

/// 指定したユーザーのfriend申請を承認します。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)approveFriend:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/approve", userID];
    [self post:path withParams:nil callback:callback];
}

/// 指定したユーザーのfriend申請を拒否します。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)denyFriend:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"users/%@/deny", userID];
    [self post:path withParams:nil callback:callback];
}

/// 指定したユーザーがチェックインしたときに通知（ping）を受け取るかどうか指定します。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)setPings:(BOOL)value forFriend:(NSString *)userID callback:(Foursquare2Callback)callback
{
    NSDictionary* params = [NSDictionary dictionaryWithObject:(value ? @"true" : @"false") forKey:@"value"];
    NSString* path = [NSString stringWithFormat:@"users/%@/setpings", userID];
    [self post:path withParams:params callback:callback];
}

#pragma mark -
#pragma mark Venues

/// VenueIDを指定して、Venue（スポット・お店など）の詳細情報を取得します。
+ (void)getDetailForVenue:(NSString *)venueID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"venues/%@", venueID];
    [self get:path withParams:nil callback:callback];
}

/// Venue（スポット・お店など）を作成します。
/// 正しい住所か、緯度経度のいずれかは必須です。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)addVenueWithName:(NSString *)name
                 address:(NSString *)address
             crossStreet:(NSString *)crossStreet
                    city:(NSString *)city
                   state:(NSString *)state
                     zip:(NSString *)zip
                   phone:(NSString *)phone
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
       primaryCategoryId:(NSString *)prmaryCategoryId
                callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (name) {
        [params setObject:name forKey:@"name"];
    }
    if (address) {
        [params setObject:address forKey:@"address"];
    }
    if (crossStreet) {
        [params setObject:crossStreet forKey:@"crossStreet"];
    }
    if (city) {
        [params setObject:city forKey:@"city"];
    }
    if (state) {
        [params setObject:state forKey:@"state"];
    }
    if (zip) {
        [params setObject:zip forKey:@"zip"];
    }
    if (phone) {
        [params setObject:phone forKey:@"phone"];
    }
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    if (primaryCategoryId) {
        [params setObject:primaryCategoryId forKey:@"primaryCategoryId"];
    }
    [self post:@"venues/add" withParams:params callback:callback];
}

/// カテゴリの一覧を取得します。
/// 最上位カテゴリは、venueに割り当てられないためIDはありません。
/// このApiの取得は頻繁にコールしないようにします。
/// 例えばアプリケーション利用の開始に１回だけダウンロードし、キャッシュに保持しておきます。
/// ただし、カテゴリ一覧は更新されますので、１週間以上キャッシュしないようにする必要があります。
+ (void)getVenueCategoriesCallback:(Foursquare2Callback)callback
{
    [self get:@"venues/categories" withParams:nil callback:callback];
}

/// 指定した地点に近いvenueを検索します。
/// OAuthで取得すると、ユーザーとfriendの情報を含むことができます。
+ (void)searchVenuesNearByLatitude:(NSString *)latitude
                         longitude:(NSString *)longitude
                        accuracyLL:(NSString *)accuracyLL
                          altitude:(NSString *)altitude
                       accuracyAlt:(NSString *)accuracyAlt
                             query:(NSString *)query
                             limit:(NSString *)limit
                            intent:(NSString *)intent
                          callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    if (accuracyLL) {
        [params setObject:accuracyLL forKey:@"llAcc"];
    }
    if (altitude) {
        [params setObject:altitude forKey:@"alt"];
    }
    if (accuracyAlt) {
        [params setObject:accuracyAlt forKey:@"altAcc"];
    }
    if (query) {
        [params setObject:query forKey:@"query"];
    }
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    if (intent) {
        [params setObject:intent forKey:@"intent"];
    }
    [self get:@"venues/search" withParams:params callback:callback];
}

#pragma mark Aspects

/// VenueIDを指定して、今Venue（スポット・お店など）にチェックインしているユーザーの一覧を取得します。
+ (void)getVenueHereNow:(NSString *)venueID
                  limit:(NSString *)limit
                 offset:(NSString *)offset
         afterTimestamp:(NSString *)afterTimestamp
               callback:(Foursquare2Callback)callback
{
    if (nil == venueID) {
        callback(NO, nil);
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    if (offset) {
        [params setObject:offset forKey:@"offset"];
    }
    if (afterTimestamp) {
        [params setObject:afterTimestamp forKey:@"afterTimestamp"];
    }
    NSString* path = [NSString stringWithFormat:@"venues/%@/herenow", venueID];
    [self get:path withParams:params callback:callback];
}

/// 指定したVenueIDのTipsを取得します。
+ (void)getTipsFromVenue:(NSString *)venueID
                    sort:(FoursquareSortingType)sort
                callback:(Foursquare2Callback)callback
{
    if (nil == venueID || sort == sortNearby) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[self sortTypeToString:sort] forKey:@"sort"];
    NSString* path = [NSString stringWithFormat:@"venues/%@/tips", venueID];
    [self get:path withParams:params callback:callback];
}

#pragma mark Actions

/// 指定したVenueIDをTODOとして印をつけます。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)markVenueToDo:(NSString *)venueID text:(NSString *)text callback:(Foursquare2Callback)callback
{
    if (nil == venueID) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (text) {
        [params setObject:text forKey:@"text"];
    }
    NSString* path = [NSString stringWithFormat:@"venues/%@/marktodo", venueID];
    [self post:path withParams:params callback:callback];
}

/// venueに間違いがあるときに、フラグをつけます。
/// 「closed」フラグが承認された場合はそのvenueは検索結果に現れなくなります。
/// 「mislocated」、「duplicate」の時は、モデレータは修正を試みます。
/// ユーザーが正しい住所を持っている(知っている)場合は、代わりに変更を提案を使ってください。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)flagVenue:(NSString *)venueID problem:(FoursquareProblemType)problem callback:(Foursquare2Callback)callback
{
    if (nil == venueID) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[self problemTypeToString:problem] forKey:@"problem"];
    NSString* path = [NSString stringWithFormat:@"venues/%@/flag", venueID];
    [self post:path withParams:params callback:callback];
}

/// venueの情報を変更する提案を行います。
/// 提案したいvenueのVENUE_IDを指定し、提案したいパラメータをセットします。
/// 変更の必要のないパラメータは省略します。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)proposeEditVenue:(NSString *)venueID
                    name:(NSString *)name
                 address:(NSString *)address
             crossStreet:(NSString *)crossStreet
                    city:(NSString *)city
                   state:(NSString *)state
                     zip:(NSString *)zip
                   phone:(NSString *)phone
                latitude:(NSString *)latitude
               longitude:(NSString *)longitude
       primaryCategoryId:(NSString *)primaryCategoryId
                callback:(Foursquare2Callback)callback
{
    if (nil == venueID) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (name) {
        [params setObject:name forKey:@"name"];
    }
    if (address) {
        [params setObject:address forKey:@"address"];
    }
    if (crossStreet) {
        [params setObject:crossStreet forKey:@"crossStreet"];
    }
    if (city) {
        [params setObject:city forKey:@"city"];
    }
    if (state) {
        [params setObject:state forKey:@"state"];
    }
    if (zip) {
        [params setObject:zip forKey:@"zip"];
    }
    if (phone) {
        [params setObject:phone forKey:@"phone"];
    }
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    if (primaryCategoryId) {
        [params setObject:primaryCategoryId forKey:@"primaryCategoryId"];
    }
    NSString* path = [NSString stringWithFormat:@"venues/%@/proposeedit", venueID];
    [self post:path withParams:params callback:callback];
}


#pragma mark -
#pragma mark Checkins

/// CheckinIDを指定して、チェックインの詳細情報を取得します。
+ (void)getDetailForCheckin:(NSString *)checkinID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"checkins/%@", checkinID];
    [self get:path withParams:nil callback:callback];
}

/// チェックインします。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)createCheckinAtVenue:(NSString *)venueID
                       venue:(NSString *)venue
                       shout:(NSString *)shout
                   broadcast:(FoursquareBroadcastType)broadcast
                    latitude:(NSString *)latitude
                   longitude:(NSString *)longitude
                  accuracyLL:(NSString *)accuracyLL
                    altitude:(NSString *)altitude
                 accuracyAlt:(NSString *)accuracyAlt
                    callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (venueID) {
        [params setObject:venueID forKey:@"venueId"];
    }
    if (venue) {
        [params setObject:venue forKey:@"venue"];
    }
    if (shout) {
        [params setObject:shout forKey:@"shout"];
    }
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    if (accuracyLL) {
        [params setObject:accuracyLL forKey:@"llAcc"];
    }
    if (altitude) {
        [params setObject:altitude forKey:@"alt"];
    }
    if (accuracyLL) {
        [params setObject:accuracyAlt forKey:@"altAcc"];
    }
    [params setObject:[self broadcastTypeToString:broadcast] forKey:@"broadcast"];

    [self post:@"checkins/add" withParams:params callback:callback];
}

/// friendが最近チェックインした場所の一覧を取得。
/// ※ページング機能の実装（limit, offset）についてCheckinの履歴を参考にしてください
+ (void)getRecentCheckinsByFriendsNearByLatitude:(NSString *)latitude
                                       longitude:(NSString *)longitude
                                           limit:(NSString *)limit
                                          offset:(NSString *)offset
                                  afterTimestamp:(NSString *)afterTimestamp
                                        callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    if (offset) {
        [params setObject:offset forKey:@"offset"];
    }
    if (afterTimestamp) {
        [params setObject:afterTimestamp forKey:@"afterTimestamp"];
    }
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    [self get:@"checkins/recent" withParams:params callback:callback];
}

#pragma mark Actions

/// チェックインにコメントを付けます。
+ (void)addCommentToCheckin:(NSString *)checkinID text:(NSString *)text callback:(Foursquare2Callback)callback
{
    if (nil == checkinID) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (text) {
        [params setObject:text forKey:@"text"];
    }
    NSString* path = [NSString stringWithFormat:@"checkins/%@/addcomment", checkinID];
    [self post:path withParams:params callback:callback];
}

/// チェックインの特定のコメントを削除します。
+ (void)deleteComment:(NSString *)commentID forCheckin:(NSString *)checkinID callback:(Foursquare2Callback)callback
{
    if (nil == checkinID) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (commentID) {
        [params setObject:commentID forKey:@"commentId"];
    }
    NSString* path = [NSString stringWithFormat:@"checkins/%@/deletecomment", checkinID];
    [self post:path withParams:params callback:callback];
}


#pragma mark -
#pragma mark Tips

/// TipIDを指定して、Tipの詳細情報を取得します。
/// TODOとDoneを付けたtipsを含みます。
+ (void)getDetailForTip:(NSString *)tipID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"tips/%@", tipID];
    [self get:path withParams:nil callback:callback];
}

/// VenueIDを指定して、Tipsを追加します。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)addTip:(NSString *)tip forVenue:(NSString *)venueID withURL:(NSString *)url callback:(Foursquare2Callback)callback
{
    if (nil == venueID || nil == tip) {
        callback(NO, nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:venueID forKey:@"venueId"];
    [params setObject:tip forKey:@"text"];
    if (url) {
        [params setObject:url forKey:@"url"];
    }
    [self post:@"tips/add" withParams:params callback:callback];
}

/// 近隣にあるTipsを検索します。
+ (void)searchTipNearbyLatitude:(NSString *)latitude
                      longitude:(NSString *)longitude
                          limit:(NSString *)limit
                         offset:(NSString *)offset 
                    friendsOnly:(BOOL)friendsOnly
                          query:(NSString *)query
                       callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (limit) {
        [params setObject:limit forKey:@"limit"];
    }
    if (offset) {
        [params setObject:offset forKey:@"offset"];
    }
    
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    if (friendsOnly) {
        [params setObject:@"friends" forKey:@"filter"];
    }
    if (query) {
        [params setObject:query forKey:@"query"];
    }
    [self get:@"tips/search" withParams:params callback:callback];
}

#pragma mark Actions

/// TipIDを指定して、TipにTODOのフラグをつけます。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)markTipTodo:(NSString *)tipID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"tips/%@/marktodo", tipID];
    [self post:path withParams:nil callback:callback];
}

/// TipIDを指定して、Tipに完了のフラグをつけます。
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)markTipDone:(NSString *)tipID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"tips/%@/markdone", tipID];
    [self post:path withParams:nil callback:callback];
}

/// TipIDを指定して、TODOリストとDONEリストからTipのフラグを外します。
/// ※本家ドキュメントのリクエストURLは誤っている？(2010/12/27)
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
+ (void)unmarkTipTodo:(NSString *)tipID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"tips/%@/unmark", tipID];
    [self post:path withParams:nil callback:callback];
}

#pragma mark -
#pragma mark Photos

/// PhotoIDを指定して、写真の詳細情報を取得します。
+ (void)getDetailForPhoto:(NSString *)photoID callback:(Foursquare2Callback)callback
{
    NSString* path = [NSString stringWithFormat:@"photos/%@", photoID];
    [self get:path withParams:nil callback:callback];
}


/// PhotoIDを指定して、写真の詳細情報を取得します。
/// パラメータのすべてはオプションですが、checkinId, tipId, venueIdのいずれか１つは必須です。
/// TipsIDまたはVenuIDを指定した場合は、誰もが見られる公開状態となります。
/// CheckinIDを指定した場合は、Checkinの公開状態に従います。（twitterやfacebookを利用してcheckinした場合はこの限りではありません）
/// ※ foursquareのPOST系はjsonpしても、ステータスコード200が返るとは限らないのでjavascriptからは厳しい？(2010/12/26)
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
+ (void)addPhoto:(NSImage*)photo
#else
+ (void)addPhoto:(UIImage*)photo
#endif
       toCheckin:(NSString *)checkinID
             tip:(NSString *)tipID
           venue:(NSString *)venueID
       broadcast:(FoursquareBroadcastType)broadcast
        latitude:(NSString *)latitude
       longitude:(NSString *)longitude
      accuracyLL:(NSString *)accuracyLL
        altitude:(NSString *)altitude
     accuracyAlt:(NSString *)accuracyAlt
        callback:(Foursquare2Callback)callback
{
    if (!checkinID && !tipID && !venueID) {
        callback(NO, nil);
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    if (latitude && longitude) {
        [params setObject:[NSString stringWithFormat:@"%@,%@", latitude, longitude] forKey:@"ll"];
    }
    if (accuracyLL) {
        [params setObject:accuracyLL forKey:@"llAcc"];
    }
    if (altitude) {
        [params setObject:altitude forKey:@"alt"];
    }
    if (accuracyAlt) {
        [params setObject:accuracyAlt forKey:@"altAcc"];
    }
    
    [params setObject:[self broadcastTypeToString:broadcast] forKey:@"broadcast"];
    if (checkinID) {
        [params setObject:checkinID forKey:@"checkinId"];
    }
    if (tipID) {
        [params setObject:tipID forKey:@"tipId"];
    }
    if (venueID) {
        [params setObject:venueID forKey:@"venueId"];
    }
    [self uploadPhoto:@"photo/add"
           withParams:params
            withImage:photo
             callback:callback];
}

#pragma mark -
#pragma mark Settings

/// 自身の設定情報を取得します。
+ (void)getAllSettingsCallback:(Foursquare2Callback)callback
{
    [self get:@"settings/all" withParams:nil callback:callback];
}

/// 
+ (void)setSendToTwitter:(BOOL)value callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:(value ? @"1" : @"0") forKey:@"value"];
    [self post:@"settings/sendToTwitter/set" withParams:params callback:callback];
}

+ (void)setSendToFacebook:(BOOL)value callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:(value ? @"1" : @"0") forKey:@"value"];
    [self post:@"settings/sendToFacebook/set" withParams:params callback:callback];
}

+ (void)setReceivePings:(BOOL)value callback:(Foursquare2Callback)callback
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:(value ? @"1" : @"0") forKey:@"value"];
    [self post:@"settings/receivePings/set" withParams:params callback:callback];
}
#pragma mark -

#pragma mark HRRequestOperation Delegates
+ (void)restConnection:(NSURLConnection*)connection
      didFailWithError:(NSError*)error
                object:(id)object
{
    Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(NO, error);
    [callback release];
}

+ (void)restConnection:(NSURLConnection*)connection
       didReceiveError:(NSError*)error
               resonse:(NSHTTPURLResponse*)response
                object:(id)object
{
    Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(NO, error);
    [callback release];
}

+ (void)restConnection:(NSURLConnection*)connection
  didReceiveParseError:(NSError*)error
          responseBody:(NSString*)string
                object:(id)object
{
    Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(NO, error);
    [callback release];
}

+ (void)restConnection:(NSURLConnection*)connection
     didReturnResource:(id)resource
                object:(id)object
{
    Foursquare2Callback callback = (Foursquare2Callback)object;
    callback(YES, resource);
    [callback release];
}

#pragma mark Private methods

+ (NSString*)broadcastTypeToString:(FoursquareBroadcastType)broadcast
{
    switch (broadcast) {
        case broadcastPublic:
            return @"public";
        case broadcastPrivate:
            return @"private";
        case broadcastFacebook:
            return @"facebook";
        case broadcastTwitter:
            return @"twitter";
        case broadcastBoth:
            return @"twitter,facebook";
        default:
            break;
    }
    return nil;
}

+ (NSString*)problemTypeToString:(FoursquareProblemType)problem
{
    switch (problem) {
        case problemClosed:
            return @"closed";
        case problemDuplicate:
            return @"duplicate";
        case problemMislocated:
            return @"mislocated";
        default:
            break;
    }
    return nil;
}

+ (NSString*)sortTypeToString:(FoursquareSortingType)type
{
    switch (type) {
        case sortNearby:
            return @"nearby";
        case sortPopular:
            return @"popular";
        case sortRecent:
            return @"recent";
        default:
            break;
    }
    return nil;
}

+ (void)get:(NSString*)methodName
 withParams:(NSDictionary *)params
   callback:(Foursquare2Callback)callback
{
    [self request:methodName withParams:params httpMethod:@"GET" callback:callback];
}

+ (void)post:(NSString *)methodName
  withParams:(NSDictionary *)params
    callback:(Foursquare2Callback)callback
{
    [self request:methodName withParams:params httpMethod:@"POST" callback:callback];
}

+ (NSDictionary*)generateFinalParamsFor:(NSDictionary*)params
{
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    [dictionary setObject:OAUTH_KEY forKey:@"client_id"];
    [dictionary setObject:OAUTH_SECRET forKey:@"client_secret"];
    NSString* accessToken = [[self classAttributes] objectForKey:@"access_token"];
    if ([accessToken length] > 0) {
        [dictionary setObject:accessToken forKey:@"oauth_token"];
    }
    
    if (params) {
        for (id key in params) {
            id value = [params objectForKey:key];
            [dictionary setObject:value forKey:key];
        }
    }
    
    return dictionary;
}

+ (void)request:(NSString *)methodName
     withParams:(NSDictionary *)params
     httpMethod:(NSString *)httpMethod
       callback:(Foursquare2Callback)callback
{
    callback = [callback copy];
    
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    
    NSString* path = [NSString stringWithFormat:@"/%@", methodName];
    [options setValue:[NSNumber numberWithInt:HRDataFormatJSON] forKey:kHRClassAttributesFormatKey];
    NSDictionary* finalParams = [self generateFinalParamsFor:params];
    
    [options setObject:finalParams forKey:kHRClassAttributesParamsKey];
    
    if ([httpMethod isEqualToString:@"GET"]) {
        [self getPath:path withOptions:options object:callback];
    } else {
        [self postPath:path withOptions:options object:callback];
    }
}

+ (void)uploadPhoto:(NSString *)methodName
         withParams:(NSDictionary *)params
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
          withImage:(NSImage*)image
#else
          withImage:(UIImage*)image
#endif
           callback:(Foursquare2Callback)callback
{
    callback = [callback copy];
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    NSString* path = [NSString stringWithFormat:@"/%@", methodName]
    [options setValue:[NSNumber numberWithInt:33] forKey:kHRClassAttributesFormatKey];
    NSDictionary* finalParams = [self generateFinalParamsFor:params];
    
    [options setObject:finalParams forKey:kHRClassAttributesParamsKey];

    NSMutableData* postBody = [NSMutableData data];
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
    NSArray* reps = [image representations];
    NSData* data = [NSBitmapImageRep representationOfImageRepsInArray:reps
                                                            usingType:NSJPEGFileType
                                                           properties:nil];
#else
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
#endif
    
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", @"0xKhTmLbOuNdArY"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data\"; filename=\"photo.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithData:data]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", @"0xKhTmLbOuNdArY"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [options setObject:postBody forKey:kHRClassAttributesBodyKey];
    [self postPath:path withOptions:options object:callback];
}

@end
