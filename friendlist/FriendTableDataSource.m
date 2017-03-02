#import "FriendTableDataSource.h"


@interface FriendCell : UITableViewCell {
}
@end

@implementation FriendCell
@end

@interface FriendTableDataSource () {
    
}

@property (strong,nonatomic) NSDictionary *settings;
@property (strong,nonatomic) NSArray *friends;
@property (strong,nonatomic) NSDictionary *namesAndKvos;
@property (strong,nonatomic) NSArray *names;
@property (strong,nonatomic) NSArray *kvoNames;

@end


@implementation FriendTableDataSource

+(id)dataSource
{
    return [[[self alloc] init] autorelease];
}

-(id)init
{
    self = [super init];
    if (self) {
        self.settings = [NSMutableDictionary dictionaryWithContentsOfFile:@"var/mobile/Library/Preferences/com.andermoran.friendlist.plist"];
        NSDictionary *namesAndKvos = [NSDictionary dictionaryWithContentsOfFile:@"/var/root/Documents/nightmared"];
        self.namesAndKvos = namesAndKvos;
        
        NSArray *names = [namesAndKvos allValues];
        names = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        self.names = names;
        NSLog(@"friendlist::name = %@", names);
        
        NSArray *kvoNames = [namesAndKvos allKeys];
        kvoNames = [kvoNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        self.kvoNames = kvoNames;
        
        if(!self.settings){
            NSMutableDictionary *settings  = [[NSMutableDictionary alloc] init];
            
            for(NSString *kvoName in self.kvoNames){
                //NSLog(@"friendlist::kvoName = %@", kvoName);
                [settings setObject:@NO forKey:kvoName];
            }
            self.settings = settings;
        }
        //NSLog(@"friendlist::self.settings = %@", self.settings);
    }
    /* add the data source as an observer to find out when the friendlistcontroller will exit so that we can save the dictionary to file */
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(friendPreferencesWillExit:)
        name:@"friendPreferencesWillExit"
        object:nil];
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Friends";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.names count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"friendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    NSString *name = [self.names objectAtIndex:indexPath.row];
    //NSLog(@"friendlist::name = %@",name);
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    NSString *knownName = name;
    NSArray *temp = [self.namesAndKvos allKeysForObject:knownName];
    NSString *kvoName = [temp lastObject];
    
    FriendCell *friendCell = (FriendCell*)cell;
    if([self.settings[kvoName] boolValue]){
        cell.backgroundColor = [UIColor lightGrayColor];
        friendCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        friendCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FriendCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *name = [NSString string];

    name = [self.names objectAtIndex:indexPath.row];
    
    // Retrieves key for given name
    NSString *knownName = name;
    NSArray *temp = [self.namesAndKvos allKeysForObject:knownName];
    NSString *kvoName = [temp lastObject];
    
    [self.settings setValue:[NSNumber numberWithBool:![self.settings[kvoName] boolValue]] forKey:kvoName];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if(cell.accessoryType == UITableViewCellAccessoryNone){
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)friendPreferencesWillExit:(NSNotification*)notification{
    NSDictionary *settings = self.settings;
    NSLog(@"friendlist::settings = %@", settings);
    NSLog(@"friendlist::Writing settings");
    [settings writeToFile:@"/var/mobile/Library/Preferences/com.andermoran.friendlist.plist" atomically:YES];
    NSLog(@"friendlist::Saved settings");
    
}

-(void)dealloc{
    [super dealloc];
    [self.settings release];
    [self.friends release];
    [self.names release];
    [self.namesAndKvos release];
    _settings = nil;
    _friends = nil;
    _names = nil;
    _namesAndKvos = nil;
}

@end
