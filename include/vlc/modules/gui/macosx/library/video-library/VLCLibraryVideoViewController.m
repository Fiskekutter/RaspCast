/*****************************************************************************
 * VLCLibraryVideoViewController.m: MacOS X interface module
 *****************************************************************************
 * Copyright (C) 2022 VLC authors and VideoLAN
 *
 * Authors: Claudio Cambra <developer@claudiocambra.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#import "VLCLibraryVideoViewController.h"

#import "extensions/NSString+Helpers.h"

#import "library/VLCLibraryController.h"
#import "library/VLCLibraryModel.h"
#import "library/VLCLibraryWindow.h"

#import "library/audio-library/VLCLibraryAudioViewController.h"

#import "library/video-library/VLCLibraryVideoCollectionViewsStackViewController.h"
#import "library/video-library/VLCLibraryVideoTableViewDataSource.h"

#import "main/VLCMain.h"

@implementation VLCLibraryVideoViewController

- (instancetype)initWithLibraryWindow:(VLCLibraryWindow *)libraryWindow
{
    self = [super init];

    if(self) {
        [self setupPropertiesFromLibraryWindow:libraryWindow];
        [self setupTableViewDataSource];
        [self setupGridViewController];
        [self setupVideoPlaceholderView];
    }

    return self;
}

- (void)setupPropertiesFromLibraryWindow:(VLCLibraryWindow *)libraryWindow
{
    NSParameterAssert(libraryWindow);
    _libraryWindow = libraryWindow;
    _libraryTargetView = libraryWindow.libraryTargetView;
    _videoLibraryView = libraryWindow.videoLibraryView;
    _videoLibrarySplitView = libraryWindow.videoLibrarySplitView;
    _videoLibraryCollectionViewsStackViewScrollView = libraryWindow.videoLibraryCollectionViewsStackViewScrollView;
    _videoLibraryCollectionViewsStackView = libraryWindow.videoLibraryCollectionViewsStackView;
    _videoLibraryGroupSelectionTableViewScrollView = libraryWindow.videoLibraryGroupSelectionTableViewScrollView;
    _videoLibraryGroupSelectionTableView = libraryWindow.videoLibraryGroupSelectionTableView;
    _videoLibraryGroupsTableViewScrollView = libraryWindow.videoLibraryGroupsTableViewScrollView;
    _videoLibraryGroupsTableView = libraryWindow.videoLibraryGroupsTableView;

    _gridVsListSegmentedControl = libraryWindow.gridVsListSegmentedControl;
    _optionBarView = libraryWindow.optionBarView;
    _librarySortButton = libraryWindow.librarySortButton;
    _librarySearchField = libraryWindow.librarySearchField;
    _placeholderImageView = libraryWindow.placeholderImageView;
    _placeholderLabel = libraryWindow.placeholderLabel;
    _emptyLibraryView = libraryWindow.emptyLibraryView;
}

- (void)setupTableViewDataSource
{
    _libraryVideoTableViewDataSource = [[VLCLibraryVideoTableViewDataSource alloc] init];
    _libraryVideoTableViewDataSource.libraryModel = VLCMain.sharedInstance.libraryController.libraryModel;
    _libraryVideoTableViewDataSource.groupsTableView = _videoLibraryGroupsTableView;
    _libraryVideoTableViewDataSource.groupSelectionTableView = _videoLibraryGroupSelectionTableView;

    [_libraryVideoTableViewDataSource setup];
}

- (void)setupGridViewController
{
    _libraryVideoCollectionViewsStackViewController = [[VLCLibraryVideoCollectionViewsStackViewController alloc] init];
    _libraryVideoCollectionViewsStackViewController.collectionsStackViewScrollView = _videoLibraryCollectionViewsStackViewScrollView;
    _libraryVideoCollectionViewsStackViewController.collectionsStackView = _videoLibraryCollectionViewsStackView;
}

- (void)setupVideoPlaceholderView
{
    _videoPlaceholderImageViewSizeConstraints = @[
        [NSLayoutConstraint constraintWithItem:_placeholderImageView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:0.f
                                      constant:182.f],
        [NSLayoutConstraint constraintWithItem:_placeholderImageView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:0.f
                                      constant:114.f],
    ];
}


#pragma mark - Show the video library view

- (void)presentVideoView
{
    for (NSView *subview in _libraryTargetView.subviews) {
        [subview removeFromSuperview];
    }

    if (_libraryVideoTableViewDataSource.libraryModel.numberOfVideoMedia == 0) { // empty library
        [self presentPlaceholderVideoLibraryView];
    } else {
        [self presentVideoLibraryView];
    }

    _librarySortButton.hidden = NO;
    _librarySearchField.enabled = YES;
    _optionBarView.hidden = YES;
}

- (void)presentPlaceholderVideoLibraryView
{
    for (NSLayoutConstraint *constraint in _libraryWindow.libraryAudioViewController.audioPlaceholderImageViewSizeConstraints) {
        constraint.active = NO;
    }
    for (NSLayoutConstraint *constraint in _videoPlaceholderImageViewSizeConstraints) {
        constraint.active = YES;
    }

    _emptyLibraryView.translatesAutoresizingMaskIntoConstraints = NO;
    [_libraryTargetView addSubview:_emptyLibraryView];
    NSDictionary *dict = NSDictionaryOfVariableBindings(_emptyLibraryView);
    [_libraryTargetView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_emptyLibraryView(>=572.)]|" options:0 metrics:0 views:dict]];
    [_libraryTargetView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_emptyLibraryView(>=444.)]|" options:0 metrics:0 views:dict]];

    _placeholderImageView.image = [NSImage imageNamed:@"placeholder-video"];
    _placeholderLabel.stringValue = _NS("Your favorite videos will appear here.\nGo to the Browse section to add videos you love.");
}

- (void)presentVideoLibraryView
{
    _videoLibraryView.translatesAutoresizingMaskIntoConstraints = NO;
    [_libraryTargetView addSubview:_videoLibraryView];
    NSDictionary *dict = NSDictionaryOfVariableBindings(_videoLibraryView);
    [_libraryTargetView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_videoLibraryView(>=572.)]|" options:0 metrics:0 views:dict]];
    [_libraryTargetView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_videoLibraryView(>=444.)]|" options:0 metrics:0 views:dict]];

    if (self.gridVsListSegmentedControl.selectedSegment == VLCGridViewModeSegment) {
        _videoLibrarySplitView.hidden = YES;
        _videoLibraryCollectionViewsStackViewScrollView.hidden = NO;
        [_libraryVideoCollectionViewsStackViewController reloadData];
    } else {
        _videoLibrarySplitView.hidden = NO;
        _videoLibraryCollectionViewsStackViewScrollView.hidden = YES;
        [_libraryVideoTableViewDataSource reloadData];
    }
}

@end
