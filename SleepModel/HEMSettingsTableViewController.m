#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>

#import "HEMSettingsTableViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl* clockStyleSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl* temperatureSegmentControl;
@end

@implementation HEMSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([SENSettings temperatureFormat] == SENTemperatureFormatCentigrade) {
        self.temperatureSegmentControl.selectedSegmentIndex = 0;
    } else {
        self.temperatureSegmentControl.selectedSegmentIndex = 1;
    }
    if ([SENSettings timeFormat] == SENTimeFormat24Hour) {
        self.clockStyleSegmentControl.selectedSegmentIndex = 0;
    } else {
        self.clockStyleSegmentControl.selectedSegmentIndex = 1;
    }
}

- (IBAction)temperatureFormatChanged:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0) {
        [SENSettings setTemperatureFormat:SENTemperatureFormatCentigrade];
    } else {
        [SENSettings setTemperatureFormat:SENTemperatureFormatFahrenheit];
    }
}

- (IBAction)clockStyleChanged:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0) {
        [SENSettings setTimeFormat:SENTimeFormat24Hour];
    } else {
        [SENSettings setTimeFormat:SENTimeFormat12Hour];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
    case 1: {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:[HEMMainStoryboard personalSegueIdentifier] sender:self];
        }
    } break;
    case 2:
        break;
    case 3:
        [SENAuthorizationService deauthorize];
        break;
    default:
        break;
    }
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section != 0;
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
