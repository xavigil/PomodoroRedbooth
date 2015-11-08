//
//  PRConstants.h
//  Pomodoro Redbooth
//
//  Created by Xavi on 05/11/15.
//  Copyright © 2015 Xavi Gil. All rights reserved.
//

#ifndef PRConstants_h
#define PRConstants_h

#define UIColorFromRGB(rgbValue) \
    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
    alpha:1.0]

#define PR_NOTIF_AUTHORIZATION_RECEIVED @"AuthorizationCode"
#define PR_NOTIF_AUTHORIZATION_RECEIVED_PARAM_CODE @"code"

#define PRIMARY_COLOR UIColorFromRGB(0xF44336)
#define SECONDARY_COLOR UIColorFromRGB(0xE57373)
#define BREAK_MODE_COLOR UIColorFromRGB(0x00BCD4)

#define FONT_GET_STARTED_TITLE [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:45.0]
#define FONT_PHASE [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:25.0]
#define FONT_TITLE [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0]
#define FONT_SECTIONS [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0]


#endif /* PRConstants_h */
