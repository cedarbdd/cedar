#import "CDRExampleRunnerViewController.h"
#import "Cedar.h"

@implementation CDRExampleRunnerViewController

#pragma mark Initialization
- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        stubRunner_ = [[CDRDefaultRunner alloc] init];
    }
    return self;
}

- (void)dealloc {
    [stubRunner_ release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    runSpecsWithCustomExampleRunner(NULL, stubRunner_);
}

- (void)viewDidUnload {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // !!! Number of spec classes?
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // !!!
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CedarExampleCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

//#pragma mark CDRExampleRunner
//- (void)exampleSucceeded:(CDRExample *)example {
//}
//
//- (void)example:(CDRExample *)example failedWithMessage:(NSString *)message {
//}
//
//- (void)example:(CDRExample *)example threwException:(NSException *)exception {
//}
//
//- (void)exampleThrewError:(CDRExample *)example {
//}
//
//- (void)examplePending:(CDRExample *)example {
//}
//
//- (int)result {
//  return 0;
//}

@end

