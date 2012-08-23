//
//  XTRepository+Commands.m
//  Xit
//
//  Created by glaullon on 7/15/11.
//

#import "XTRepository+Commands.h"


@implementation XTRepository (Commands)


- (bool)initializeRepository {
    NSError *error = nil;
    bool res = false;

    [self executeGitWithArgs:[NSArray arrayWithObject:@"init"] error:&error];

    if (error == nil)
        res = true;

    return res;
}

- (bool)stash:(NSString *)name {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"stash", @"save", name, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (bool)createBranch:(NSString *)name {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"checkout", @"-b", name, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (NSString *)currentBranch {
    NSError *error = nil;
    NSData *output = [self executeGitWithArgs:[NSArray arrayWithObject:@"branch"] error:&error];

    if (output == nil)
        return nil;

    NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    NSArray *lines = [outputString componentsSeparatedByString:@"\n"];

    for (NSString *line in lines) {
        if ([line hasPrefix:@"*"])
            return [line substringFromIndex:2];
    }
    return nil;
}

- (bool)merge:(NSString *)name {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"merge", @"--no-ff", name, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (bool)push:(NSString *)remote {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"push", @"--all", @"--force", remote, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (bool)checkout:(NSString *)branch error:(NSError **)resultError {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"checkout", branch, nil] error:&error];

    if (error == nil) {
        res = YES;
    }
    if (resultError != NULL)
        *resultError = error;

    return res;
}

- (bool)createTag:(NSString *)name withMessage:(NSString *)msg {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"tag", @"-a", name, @"-m", msg, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (bool)addRemote:(NSString *)name withUrl:(NSString *)url {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"remote", @"add", name, url, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (bool)addFile:(NSString *)file {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"add", file, nil] error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (bool)commitWithMessage:(NSString *)message {
    NSError *error = nil;
    bool res = NO;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"commit", @"-F", @"-", nil] withStdIn:message error:&error];

    if (error == nil) {
        res = YES;
    }

    return res;
}

- (NSString *)diffForStagedFile:(NSString *)file {
    NSData *output = [self executeGitWithArgs:[NSArray arrayWithObjects:@"diff-index",  @"--patch", @"--cached", [self parentTree], @"--", file, nil] error:nil];

    if (output == nil)
        return nil;
    return [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)diffForUnstagedFile:(NSString *)file {
    NSData *output = [self executeGitWithArgs:[NSArray arrayWithObjects:@"diff-files", @"--patch", @"--", file, nil] error:nil];

    if (output == nil)
        return nil;
    return [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)diffForCommit:(NSString *)sha {
    NSData *output = [self executeGitWithArgs:[NSArray arrayWithObjects:@"diff-tree", @"--root", @"--cc", @"-C90%", @"-M90%", sha, nil] error:NULL];

    return [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
}

- (BOOL)stagePatch:(NSString *)patch {
    NSError *error = nil;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"apply",  @"--cached", nil]
                   withStdIn:patch
                       error:&error];
    return error == nil;
}

- (BOOL)unstagePatch:(NSString *)patch {
    NSError *error = nil;

    [self executeGitWithArgs:[NSArray arrayWithObjects:@"apply",  @"--cached", @"--reverse", nil]
                   withStdIn:patch
                       error:&error];
    return error == nil;
}

@end
