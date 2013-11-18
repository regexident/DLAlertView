//
//  DLAVViewController.m
//  DLAlertView
//
//  Created by Vincent Esche on 01/11/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import "DLAVViewController.h"

#import "DLAVUsecase.h"
#import "DLAVUsecaseSection.h"
#import "DLAVDelegate.h"

#import "DLAVAlertView.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertViewTextFieldTheme.h"
#import "DLAVAlertViewButtonTheme.h"

@interface DLAVViewController ()

@property (readwrite, strong, nonatomic) NSArray *usecases;
@property (readwrite, strong, nonatomic) NSArray *sections;
@property (readwrite, strong, nonatomic) DLAVDelegate *delegate;

@end

@implementation DLAVViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		_usecases = [self prepareUsecases];
		_sections = [self prepareSectionsForUsecases:_usecases];
		_delegate = [[DLAVDelegate alloc] init];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
		_usecases = [self prepareUsecases];
		_sections = [self prepareSectionsForUsecases:_usecases];
		_delegate = [[DLAVDelegate alloc] init];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIEdgeInsets contentInset = self.tableView.contentInset;
	contentInset.top = 20.0;
	self.tableView.contentInset = contentInset;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ((DLAVUsecaseSection *)self.sections[section]).objectIndexes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return ((DLAVUsecaseSection *)self.sections[section]).name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	cell.textLabel.text = [@"Alert with " stringByAppendingString:[self usecaseAtIndexPath:indexPath].name];
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 30.0)];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, tableView.bounds.size.width - 20, 30.0)];
	headerView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
	headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
	[headerView addSubview:headerLabel];
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self usecaseAtIndexPath:indexPath].block();
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (DLAVUsecase *)usecaseAtIndexPath:(NSIndexPath *)indexPath {
	DLAVUsecaseSection *section = self.sections[indexPath.section];
	NSUInteger usecaseIndex = [section.objectIndexes firstIndex] + indexPath.row;
	return self.usecases[usecaseIndex];
}

- (NSArray *)prepareUsecases {
	NSMutableArray *usecases = [NSMutableArray array];
	
	self.delegate = [[DLAVDelegate alloc] init];
	
	// Simple Alerts:
	
	NSUInteger sectionIndex = 1;
	
	NSString * const alertsSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Simple Alerts"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"one button" sectionName:alertsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"One button!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"two buttons" sectionName:alertsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Two button!" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"many buttons" sectionName:alertsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Many buttons!" message:nil delegate:nil cancelButtonTitle:@"One" otherButtonTitles:@"Two", @"Three", @"Four", nil];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	// Simple Alerts with Message:
	
	NSString * const alertsWithMessageSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Simple Alerts with Message"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"short message" sectionName:alertsWithMessageSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Tap OK!" message:@"You have no choice anyway!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"long message" sectionName:alertsWithMessageSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Tap OK!" message:@"As if you had any other choice! I mean, do you see any other button, than 'OK'? I could have given you one, but I didn't." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"even longer message" sectionName:alertsWithMessageSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Lorem ipsum…" message:@"…dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	// Alerts with Custom View:
	
	NSString * const alertsWithContentViewSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Alerts with Content View"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"a content view" sectionName:alertsWithContentViewSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Look, a view!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		alertView.contentView = contentView;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	// Alerts with Delegate:
	
	NSString * const alertsWithDelegateSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Alerts with a Delegate"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"a delegate" sectionName:alertsWithDelegateSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Watch the console!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		alertView.delegate = self.delegate;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	// Alerts with Textfields:
	
	NSString * const alertsWithTextFieldsSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Alerts with Textfields"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"a textfield" sectionName:alertsWithTextFieldsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Look, a textfield!" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		alertView.alertViewStyle = DLAVAlertViewStylePlainTextInput;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%p' at index: %ld (with input: '%@')", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex, [alertView textFieldTextAtIndex:0]);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"a secret field" sectionName:alertsWithTextFieldsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Look, a secure textfield!" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		alertView.alertViewStyle = DLAVAlertViewStyleSecureTextInput;
		alertView.delegate = self.delegate;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%p' at index: %ld (with secret input: '%@')", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex, [alertView textFieldTextAtIndex:0]);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"login textfields" sectionName:alertsWithTextFieldsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Look, login fields!" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		alertView.alertViewStyle = DLAVAlertViewStyleLoginAndPasswordInput;
		alertView.delegate = self.delegate;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%p' at index: %ld (with login: '%@', password: '%@')", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex, [alertView textFieldTextAtIndex:0], [alertView textFieldTextAtIndex:1]);
		}];
	}]];
	
	// Alerts with dynamic Elements:
	
	NSString * const alertsWithDynamicElementsSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Themed Alerts"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"dynamic alert view style" sectionName:alertsWithDynamicElementsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Wait for it…" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			alertView.title = @"Now look at that!";
			alertView.alertViewStyle = DLAVAlertViewStyleLoginAndPasswordInput;
		});
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			alertView.title = @"One more time!";
			alertView.alertViewStyle = DLAVAlertViewStyleSecureTextInput;
		});
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			alertView.title = @"Okay, that's it for now.";
			alertView.alertViewStyle = DLAVAlertViewStyleDefault;
		});
		alertView.delegate = self.delegate;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%p' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"dynamic elements" sectionName:alertsWithDynamicElementsSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Wait for it…" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
		contentView.backgroundColor = [UIColor colorWithHue:0.0 saturation:0.5 brightness:1.0 alpha:1.0];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			alertView.message = @"How about a textfield?";
			[alertView addButtonWithTitle:@"Yay!"];
		});
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			alertView.message = @"Hooray!";
			[alertView addTextFieldWithText:nil placeholder:@"That was fun!"];
		});
		alertView.delegate = self.delegate;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%p' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	// Alerts with custom Theme:
	
	NSString * const alertsWithCustomThemeSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Themed Alerts"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"HUD theme" sectionName:alertsWithCustomThemeSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Fancy!" message:nil delegate:nil cancelButtonTitle:@"It is!" otherButtonTitles:nil, nil];
		[alertView applyTheme:[DLAVAlertViewTheme themeWithStyle:DLAVAlertViewThemeStyleHUD]];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"butt ugly theme" sectionName:alertsWithCustomThemeSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Yuck!" message:@"Now that's ugly!" delegate:nil cancelButtonTitle:@"Be gone!" otherButtonTitles:nil, nil];
		DLAVAlertViewTheme *theme = [DLAVAlertViewTheme defaultTheme];
		theme.backgroundColor = [UIColor yellowColor];
		theme.borderColor = [UIColor redColor];
		theme.borderWidth = 2.0;
		theme.titleColor = [UIColor blueColor];
		theme.messageColor = [UIColor purpleColor];
		theme.titleFont = [UIFont fontWithName:@"Zapfino" size:15.0f];
		theme.messageFont = [UIFont fontWithName:@"Marker Felt" size:theme.messageFont.pointSize];
		DLAVAlertViewButtonTheme *buttonTheme = [DLAVAlertViewButtonTheme theme];
		buttonTheme.backgroundColor = [UIColor blueColor];
		buttonTheme.highlightBackgroundColor = [UIColor redColor];
		buttonTheme.textColor = [UIColor greenColor];
		[alertView setCustomButtonTheme:buttonTheme forButtonAtIndex:0];
		[alertView applyTheme:theme];
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"live changing theme" sectionName:alertsWithCustomThemeSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Fancy!" message:nil delegate:nil cancelButtonTitle:@"It is!" otherButtonTitles:nil, nil];
		double delayInSeconds = 1.5;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[alertView applyTheme:[DLAVAlertViewTheme themeWithStyle:DLAVAlertViewThemeStyleHUD] animated:YES];
		});
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
		}];
	}]];
	
	// Alerts with backdrop tap dismissal:
	
	NSString * const alertsWithBackdropTapDismissalSectionName = [NSString stringWithFormat:@"%lu: %@", (unsigned long)sectionIndex++, @"Themed Alerts"];
	
	[usecases addObject:[DLAVUsecase usecaseWithName:@"backdrop tap dismissal" sectionName:alertsWithBackdropTapDismissalSectionName block:^{
		DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"Tap outside me!" message:nil delegate:nil cancelButtonTitle:@"Not here!" otherButtonTitles:nil, nil];
		alertView.dismissesOnBackdropTap = YES;
		[alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
			if (buttonIndex == -1) {
				NSLog(@"Tapped backdrop!");
			} else {
				NSLog(@"Tapped button '%@' at index: %ld", [alertView buttonTitleAtIndex:buttonIndex], (long)buttonIndex);
			}
		}];
	}]];
	
	return usecases;
}

- (NSArray *)prepareSectionsForUsecases:(NSArray *)usecases {
	NSMutableArray *sections = [NSMutableArray array];
	if (!usecases.count) {
		return sections;
	}
	NSArray *sortedUsecases = [usecases sortedArrayUsingComparator:^NSComparisonResult(DLAVUsecase *usecase1, DLAVUsecase *usecase2) {
		return [usecase1.sectionName localizedCompare:usecase2.sectionName];
	}];
	__block NSString *sectionName = ((DLAVUsecase *)sortedUsecases[0]).sectionName;
	__block NSMutableIndexSet *sectionIndexes = [NSMutableIndexSet indexSetWithIndex:0];
	[sortedUsecases enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, sortedUsecases.count - 1)] options:0 usingBlock:^(DLAVUsecase *usecase, NSUInteger index, BOOL *stop) {
		if (![usecase.sectionName isEqual:sectionName]) {
			[sections addObject:[DLAVUsecaseSection sectionWithName:sectionName objectIndexes:sectionIndexes]];
			sectionName = usecase.sectionName;
			sectionIndexes = [NSMutableIndexSet indexSetWithIndex:index];
		}
		[sectionIndexes addIndex:index];
	}];
	[sections addObject:[DLAVUsecaseSection sectionWithName:sectionName objectIndexes:sectionIndexes]];
	return sections;
}

@end
