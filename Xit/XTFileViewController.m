//
//  XTFileViewController.m
//  Xit
//
//  Created by German Laullon on 15/09/11.
//

#import "XTFileViewController.h"
#import "XTHistoryItem.h"
#import "XTCommitDetailsViewController.h"
#import "XTRepository+FileVIewCommands.h"
#import "XTHTML.h"
#import "XTFileListHistoryDataSource.h"
#import "XTTrackingTableView.h"

@implementation XTFileViewController

- (NSString *)nibName {
    NSLog(@"nibName: %@ (%@)", [super nibName], [self class ]);
    return NSStringFromClass([self class ]);
}

- (void)setRepo:(XTRepository *)newRepo {
    repo = newRepo;
    [fileListDS setRepo:repo];
    [fileListHistoryDS setRepo:repo];
    [fileHistoryDS setRepo:repo];
    fileHistoryDS.useFile = YES;
    [path setURL:[repo repoURL]];
    [repo addObserver:self forKeyPath:@"selectedCommit" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reload {
    if (!fileName) return;

    NSString *file = [repo show:fileName inSha:repo.selectedCommit];
    NSString *html = [NSString stringWithFormat:@"<html><body><pre id='file'>%@</pre></body></html>", [XTHTML escapeHTML:file]];
    NSBundle *bundle = [NSBundle mainBundle];
    NSBundle *theme = [NSBundle bundleWithURL:[bundle URLForResource:@"html.theme.default" withExtension:@"bundle"]];
    NSURL *themeURL = [[theme bundleURL] URLByAppendingPathComponent:@"Contents/Resources"];

    NSURL *url = [NSURL URLWithString:[fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [filePath setURL:url];
    fileHistoryDS.file = fileName;

    dispatch_async(dispatch_get_main_queue(), ^{
                       [[web mainFrame] loadHTMLString:html baseURL:themeURL];
                   });

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedCommit"]) {
        [self reload];
    }
}

#pragma mark - NSOutlineViewDelegate
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSOutlineView *fileList = (NSOutlineView *)notification.object;
    NSTreeNode *node = [fileList itemAtRow:fileList.selectedRow];

    fileName = (NSString *)node.representedObject;
    [self reload];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"fileCell" owner:self];
    NSTreeNode *node = (NSTreeNode *)item;
    NSString *name = (NSString *)node.representedObject;

    // TODO: cache the file icon extending NSTreeNode....
    cell.imageView.image = [[NSWorkspace sharedWorkspace] iconForFile:[repo.repoURL.path stringByAppendingPathComponent:name]];
    cell.textField.stringValue = [name lastPathComponent];

    return cell;
}

#pragma mark - XTTrackingTableDelegate

- (void)tableView:(XTTrackingTableView *)aTable mouseOverRow:(NSInteger)row {
    if (row >= 0) {
        XTFileListHistoryDataSource *ds = [aTable dataSource];
        XTHistoryItem *item = [[ds items] objectAtIndex:row];
        commitView.sha.stringValue = item.sha;
        commitView.subject.stringValue = item.subject;
        [popover showRelativeToRect:[aTable rectOfRow:row] ofView:(NSView *)aTable preferredEdge:NSMinXEdge];
    } else {
        [popover close];
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSLog(@"%@", aNotification);
    XTTrackingTableView *aTable = (XTTrackingTableView *)aNotification.object;
    XTFileListHistoryDataSource *ds = [aTable dataSource];
    if (aTable.selectedRow > 0) {
        XTHistoryItem *item = [[ds items] objectAtIndex:aTable.selectedRow];
        repo.selectedCommit = item.sha;
    }
}

// TODO: bad....
// - (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
//    NSTextFieldCell *cell = aCell;
//    if ([(XTTrackingTableView)aTableView mouseOverRow] == rowIndex) {
//        cell.backgroundColor = [NSColor selectedMenuItemColor];
//        cell.drawsBackground = YES;
//    } else {
//        cell.backgroundColor = [NSColor controlBackgroundColor];
//        cell.drawsBackground = NO;
//    }
// }


@end