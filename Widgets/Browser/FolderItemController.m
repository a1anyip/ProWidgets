//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "FolderItemController.h"
#import "Browser.h"
#import "interface.h"
#import "../../PWThemableTableView.h"
#import "../../PWThemableTableViewCell.h"

@implementation PWBrowserWidgetItemFolderController

+ (void)getDefaultSelectedTitle:(NSString **)selectedTitleOut selectedIdentifier:(NSUInteger *)selectedIdentifierOut {
	WebBookmarkCollection *collection = [WebBookmarkCollection safariBookmarkCollection];
	WebBookmark *rootBookmark = collection.rootBookmark;
	NSUInteger rootId = rootBookmark.identifier;
	NSArray *rootSubfolders = [collection subfoldersOfID:rootId];
	if ([rootSubfolders count] > 0) {
		WebBookmark *firstSubfolder = rootSubfolders[0];
		*selectedTitleOut = firstSubfolder.localizedTitle;
		*selectedIdentifierOut = firstSubfolder.identifier;
	}
}

- (instancetype)initForWidget:(PWWidget *)widget {
	if ((self = [super initForWidget:widget])) {
		self.wantsFullscreen = YES;
		
		NSString *defaultSelectedTitle;
		NSUInteger defaultSelectedIdentifier;
		[self.class getDefaultSelectedTitle:&defaultSelectedTitle selectedIdentifier:&defaultSelectedIdentifier];
		
		_selectedTitle = [defaultSelectedTitle copy];
		_selectedIdentifier = defaultSelectedIdentifier;
		
		[self loadFolders];
	}
	return self;
}

- (NSString *)title {
	return @"Location";
}

- (void)loadView {
	PWThemableTableView *view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:self.theme] autorelease];
	view.delegate = self;
	view.dataSource = self;
	self.view = view;
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	//[self resetState];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
	NSDictionary *folder = _folders[row];
	NSNumber *indentation = folder[@"indentation"];
	return [indentation integerValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	
	NSDictionary *folder = _folders[row];
	NSNumber *identifier = folder[@"identifier"];
	NSString *title = folder[@"title"];
	
	[_selectedTitle release];
	_selectedTitle = [title copy];
	_selectedIdentifier = [identifier unsignedIntegerValue];
	
	[tableView reloadData];
	[_delegate performSelector:@selector(selectedFolderChanged)];
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_folders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	
	NSString *reuseIdentifier = @"PWBrowserWidgetItemFolderControllerTableViewCell";
	PWThemableTableViewCell *cell = (PWThemableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	
	if (!cell) {
		
		cell = [[[PWThemableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier theme:self.theme] autorelease];
	}
	
	PWWidgetBrowser *widget = (PWWidgetBrowser *)self.widget;
	NSDictionary *folder = _folders[row];
	NSNumber *identifier = folder[@"identifier"];
	NSString *title = folder[@"title"];
	
	BOOL selected = _selectedIdentifier == [identifier unsignedIntegerValue];
	
	cell.textLabel.text = title;
	cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.imageView.image = [widget folderIcon];
	
	return cell;
}

- (void)loadFolders {
	
	PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
	
	if (defaultBrowser == PWWidgetBrowserDefaultSafari) {
		
		WebBookmarkCollection *collection = [WebBookmarkCollection safariBookmarkCollection];
		
		WebBookmark *rootBookmark = collection.rootBookmark;
		NSUInteger rootId = rootBookmark.identifier;
		NSArray *rootSubfolders = [collection subfoldersOfID:rootId];
		
		__block NSUInteger indentation = 0;
		NSMutableArray *folders = [NSMutableArray array];
		
		__block void(^processFolder)(WebBookmark *) = ^void(WebBookmark *folder) {
			
			BOOL isWebFilterWhiteListFolder = folder.isWebFilterWhiteListFolder;
			BOOL isReadingListFolder = folder.isReadingListFolder;
			if (isWebFilterWhiteListFolder || isReadingListFolder) return;
			
			NSUInteger identifier = folder.identifier;
			NSString *title = folder.localizedTitle;
			
			if (title == nil) title = @"";
			
			NSDictionary *row = @{ @"identifier": @(identifier), @"title": title, @"indentation": @(indentation) };
			[folders addObject:row];
			
			NSArray *subfolders = [collection subfoldersOfID:identifier];
			indentation++;
			for (WebBookmark *subBookmark in subfolders) {
				processFolder(subBookmark);
			}
			indentation--;
		};
		
		for (WebBookmark *subBookmark in rootSubfolders) {
			processFolder(subBookmark);
		}
		
		[_folders release];
		_folders = [folders retain];
			
	} else if (defaultBrowser == PWWidgetBrowserDefaultChrome) {
		
		//NSDictionary *dict = [PWWidgetBrowser readChromeBookmarks];
		
	}
	
	[self.tableView reloadData];
}

- (void)dealloc {
	RELEASE(_selectedTitle)
	RELEASE(_folders)
	[super dealloc];
}

@end