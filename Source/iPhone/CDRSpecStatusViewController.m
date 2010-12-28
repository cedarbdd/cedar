#import "CDRSpecStatusViewController.h"
#import "CDRExampleGroup.h"
#import "CDRExample.h"
#import "CDRSpecStatusCell.h"
#import "CDRExampleDetailsViewController.h"
#import "CDRSpecStatusBubble.h"
#import "CDRExampleStateMap.h"

#import <QuartzCore/QuartzCore.h>

@interface CDRSpecStatusViewController ()
- (void)CDR_pushStatusViewForExample:(CDRExampleGroup *)example;
- (void)CDR_updateCellForExampleBase:(id)example;
- (void)CDR_updateCellForGroup:(CDRExampleGroup *)group;
- (void)CDR_updateCellForExample:(CDRExample *)example;
- (void)CDR_startObservingExamples;
- (void)CDR_stopObservingExamples;
- (UITableViewCell *)CDR_tableView:(UITableView *)tableView groupCellForExampleGroup:(CDRExampleGroup *)group;
- (UITableViewCell *)CDR_tableView:(UITableView *)tableView groupCellForExample:(CDRExample *)example;
@end

@implementation CDRSpecStatusViewController

#pragma mark -
#pragma mark Initialization

- (id)initWithExamples:(NSArray *)examples
{
    if((self = [super initWithStyle:UITableViewStylePlain]))
    {
        examples_ = [examples retain];
        
        [self CDR_startObservingExamples];
    }
    return self;
}

- (void)dealloc
{
    [self CDR_stopObservingExamples];
    
    [examples_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelectorOnMainThread:@selector(CDR_updateCellForExampleBase:) withObject:object waitUntilDone:NO];
}

- (void)CDR_startObservingExamples
{
    NSIndexSet *allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [examples_ count])];
    
    [examples_ addObserver:self toObjectsAtIndexes:allIndexes forKeyPath:@"progress" options:0 context:NULL];
}

- (void)CDR_stopObservingExamples
{
    NSIndexSet *allIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [examples_ count])];
    
    [examples_ removeObserver:self fromObjectsAtIndexes:allIndexes forKeyPath:@"progress"];
}

- (void)CDR_updateCellForExampleBase:(id)example;
{
    if([example isKindOfClass:[CDRExampleGroup class]])
        [self CDR_updateCellForGroup:(CDRExampleGroup *)example];
    else
        [self CDR_updateCellForExample:example];
}

- (void)CDR_updateCellForExample:(CDRExample *)example;
{
    NSUInteger idx = [examples_ indexOfObject:example];
    
    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    
    if(cell != nil) [(CDRSpecStatusBubble *) [cell accessoryView] setState:[example state]];
}

- (void)CDR_updateCellForGroup:(CDRExampleGroup *)group;
{
    NSUInteger idx = [examples_ indexOfObject:group];
    
    if(idx == NSNotFound) return;
    
    CDRSpecStatusCell *cell = (CDRSpecStatusCell *) [[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    
    if(cell == nil || ![cell isKindOfClass:[CDRSpecStatusCell class]]) return;
    
    [cell setTotalCount:  [group numberOfExamples]];
    
    [cell setErrorCount:  [group numberOfErrors]];
    [cell setFailureCount:[group numberOfFailures]];
    [cell setPendingCount:[group numberOfPendingExamples]];
    [cell setSuccessCount:[group numberOfSuccesses]];
}

#pragma mark -
#pragma mark Private interface

- (void)CDR_pushStatusViewForExample:(CDRExampleGroup *)example
{
    UIViewController *subController = [[CDRSpecStatusViewController alloc] initWithExamples:[example examples]];
    [subController setTitle:[example text]];
    [[self navigationController] pushViewController:subController animated:YES];
    [subController release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [examples_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id example = [examples_ objectAtIndex:[indexPath row]];
    
    static NSString *ExampleCellIdentifier = @"CedarExampleCell";
    
    UITableViewCell *cell = nil;
    
    if([example isKindOfClass:[CDRExampleGroup class]] && [example hasChildren])
        cell = [self CDR_tableView:tableView groupCellForExampleGroup:example];
    else
        cell = [self CDR_tableView:tableView groupCellForExample:example];
    
    return cell;
}

- (UITableViewCell *)CDR_tableView:(UITableView *)tableView groupCellForExampleGroup:(CDRExampleGroup *)group;
{
    static NSString *GroupCellIdentifier = @"GroupCellIdentifier";
    
    CDRSpecStatusCell *cell = (CDRSpecStatusCell *) [tableView dequeueReusableCellWithIdentifier:GroupCellIdentifier];
    
    if(cell == nil)
    {
        cell = [[[CDRSpecStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupCellIdentifier] autorelease];
    }
    
    [cell setTestTitle:[group text]];
    
    [cell setTotalCount:[group numberOfExamples]];
    
    [cell setErrorCount:[group numberOfErrors]];
    [cell setFailureCount:[group numberOfFailures]];
    [cell setPendingCount:[group numberOfPendingExamples]];
    [cell setSuccessCount:[group numberOfSuccesses]];
    
    [cell setAccessoryType:([group hasChildren] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone)];
    
    return cell;
}

- (UITableViewCell *)CDR_tableView:(UITableView *)tableView groupCellForExample:(CDRExample *)example;
{
    static NSString *CellIdentifier = @"CedarExampleCell";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryView:[[[CDRSpecStatusBubble alloc] init] autorelease]];
    }
    
    [[cell textLabel] setText:[example text]];
    [[cell detailTextLabel] setText:[[CDRExampleStateMap stateMap] descriptionForState:[example state]]];
    [(CDRSpecStatusBubble *) [cell accessoryView] setState:[example state]];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDRExampleGroup *example = [examples_ objectAtIndex:[indexPath row]];
    
    return ([example isKindOfClass:[CDRExampleGroup class]] && [example hasChildren] ? 67.0 : 44.0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id selectedExample = [examples_ objectAtIndex:indexPath.row];
    
    if([selectedExample hasChildren])
        [self CDR_pushStatusViewForExample:selectedExample];
    else
    {
        CDRExampleDetailsViewController *exampleDetailsController = [[CDRExampleDetailsViewController alloc] initWithExample:selectedExample];
        exampleDetailsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:exampleDetailsController animated:YES];
        [exampleDetailsController release];
    }
}

@end

