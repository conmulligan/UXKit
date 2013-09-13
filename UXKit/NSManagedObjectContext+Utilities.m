//
//  NSManagedObjectContext+Utilities.m
//  UXKit
//
//  Copyright 2012 Conor Mulligan. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSManagedObjectContext+Utilities.h"

@implementation NSManagedObjectContext (Utilities)

- (id)createObject:(Class)entity {
    return [NSEntityDescription insertNewObjectForEntityForName:[entity description] inManagedObjectContext:self];
}

- (NSArray *)fetchEntities:(Class)entity {
    return [self fetchEntities:entity withPredicate:nil sortDescriptor:nil];
}

- (NSArray *)fetchEntities:(Class)entity withPredicate:(NSPredicate *)predicate {
    return [self fetchEntities:entity withPredicate:predicate sortDescriptor:nil];
}

- (NSArray *)fetchEntities:(Class)entity withSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    return [self fetchEntities:entity withPredicate:nil sortDescriptor:sortDescriptor];
}

- (NSArray *)fetchEntities:(Class)entity withPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)sortDescriptor {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[entity description]];
    
    if (predicate) {
        [request setPredicate:predicate];
    }
    if (sortDescriptor) {
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    NSError *error = nil;
    return [self executeFetchRequest:request error:&error];   
}

@end
