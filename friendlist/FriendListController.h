#include <Preferences/PSViewController.h>

@class FriendTableDataSource;

@interface FriendListController : PSViewController

@property (strong,nonatomic) FriendTableDataSource *dataSource;

@end
