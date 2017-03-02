#include "NightmareListRootListController.h"
#include <spawn.h>

@implementation NightmareListRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Nightmare" target:self] retain];
	}
	return _specifiers;
}

// Color picker
- (void)viewWillAppear:(BOOL)animated {
	//[self clearCache];
	[self reload];  
    [super viewWillAppear:animated];
}

// email me
-(void)email {
	NSString *recipients = @"mailto:andermorandeveloper@gmail.com?subject=[Nightmare] keep the subject brief!";
	NSString *body = @"&body=Device:\niOS:\nIssue:\nScreenshots:\nSSN and name of first born son:\n";

	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

// follow my twitter
-(void)twitter {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:@"andermorandev"]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:@"andermorandev"]]];
	}
}

// add me on snapchat
-(void)snapchat {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"snapchat:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"snapchat://add/" stringByAppendingString:@"notander"]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://www.snapchat.com/add/" stringByAppendingString:@"notander"]]];
	}
}

// donate through venmo
-(void)venmo {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"venmo:"]]) {
		// My specific venmo user ID
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"venmo://users/" stringByAppendingString:@"9831007"]]];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to open Venmo" 
														message:@"Whoops! Looks like you don't have Venmo installed!" 
														delegate:self 
														cancelButtonTitle:@"OK" 
														otherButtonTitles:nil];
		[alert show];
	}
}

// Apply changes
-(void)apply {
	/* use the springboard's relaunchSpringBoardNow function to respring */
	pid_t pid;
	int status;
	const char *argv[] = {"killall", "SpringBoard", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
	waitpid(pid, &status, WEXITED);
}

// Link to my repo
-(void)repo {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://url/https://cydia.saurik.com/api/share#?source=http%3A%2F%2Fandermoran.github.io/"]];
}

// WORK IN PROGRESS
- (void)toggleHideInfoInteraction {
	//self.kHideInfo.userInteractionEnabled = NO;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ROFL" 
													message:@"Dee dee doo doo." 
													delegate:self 
													cancelButtonTitle:@"OK" 
													otherButtonTitles:nil];
	[alert show];
}

@end


