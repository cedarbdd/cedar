#import "CDRSpecStatusViewController.h"
#import "CDRExampleGroup.h"
#import "SpecStatusCell.h"

@interface CDRSpecStatusViewController (Private)
- (void)pushStatusViewForExamples:(NSArray *)examples;
@end

@implementation CDRSpecStatusViewController

#pragma mark -
#pragma mark Initialization
- (id)initWithExamples:(NSArray *)examples {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        examples_ = [examples retain];
    }
    return self;
}

- (void)dealloc {
    [examples_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [examples_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CedarExampleCell";

    id cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[SpecStatusCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }

    [cell setExample:[examples_ objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedExample = [examples_ objectAtIndex:indexPath.row];
    if ([selectedExample hasChildren]) {
        [self pushStatusViewForExamples:[selectedExample examples]];
    } else {
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    }
}

#pragma mark Private interface
- (void)pushStatusViewForExamples:(NSArray *)examples {
    UIViewController *subController = [[CDRSpecStatusViewController alloc] initWithExamples:examples];
    [self.navigationController pushViewController:subController animated:YES];
    [subController release];
}

@end

