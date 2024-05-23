//
//  ProgressViewController.m
//  TodoApp
//
//  Created by Aya on 17/04/2024.
//

#import "ProgressViewController.h"
#import "Task.h"
#import "AddTaskViewController.h"
@interface ProgressViewController ()
@property NSMutableArray<Task *> * tasksInProgress;
@property (weak, nonatomic) IBOutlet UIButton *filterBtn;
@property (weak, nonatomic) IBOutlet UITableView *progressTable;
@property (weak, nonatomic) IBOutlet UIImageView *emptyimg;
@property (nonatomic, strong) NSMutableArray<Task *> *lowPriorityTasks;
@property (nonatomic, strong) NSMutableArray<Task *> *mediumPriorityTasks;
@property (weak, nonatomic) IBOutlet UILabel *ops;
@property (nonatomic, strong) NSMutableArray<Task *> *highPriorityTasks;
@property Task *task;
@property BOOL isFilter;
@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _progressTable.dataSource = self;
    _progressTable.delegate = self;
}
- (IBAction)filter:(id)sender {
    if (_isFilter) {
        _isFilter = false;
        [self.progressTable reloadData];
    } else {
        _isFilter = true;
        NSMutableArray<Task *> *lowPriorityTasks = [NSMutableArray array];
        NSMutableArray<Task *> *mediumPriorityTasks = [NSMutableArray array];
        NSMutableArray<Task *> *highPriorityTasks = [NSMutableArray array];
        
        for (Task *task in _tasksInProgress) {
            if ([task.priority isEqualToString:@"low"]) {
                [lowPriorityTasks addObject:task];
            } else if ([task.priority isEqualToString:@"medium"]) {
                [mediumPriorityTasks addObject:task];
            } else if ([task.priority isEqualToString:@"high"]) {
                [highPriorityTasks addObject:task];
            }
        }
        _lowPriorityTasks = lowPriorityTasks;
        _mediumPriorityTasks = mediumPriorityTasks;
        _highPriorityTasks = highPriorityTasks;
        
        [self.progressTable reloadData]; // Reload table view to show the filtered view
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getInTasks];
    if(_tasksInProgress.count == 0) {
        UIImage *img = [UIImage imageNamed:@"emptyimage"];
        _emptyimg.image = img;
        _ops.text = @"Opps..it's empty";
    }else{
        _ops.text=@"";
    }
    _filterBtn = false;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_isFilter){
        return 3;
    }
    return 1;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_isFilter){
        if (section == 0) {
            return _lowPriorityTasks.count;
        } else if (section == 1) {
            return _mediumPriorityTasks.count;
        } else {
            return _highPriorityTasks.count;
        }
    }
    if(_tasksInProgress.count == 0){
        UIImage *img = [UIImage imageNamed:@"emptyimage"];
        _emptyimg.image = img;
        _emptyimg.hidden = NO;
        _ops.text = @"Opps..it's empty";
    }else{
        _emptyimg.hidden = YES;
        _ops.text=@"";
        
    }
    return _tasksInProgress.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"progresscell"];

    if(_isFilter){
          Task *task;
          if (indexPath.section == 0) {
              task = _lowPriorityTasks[indexPath.row];
          } else if (indexPath.section == 1) {
              task = _mediumPriorityTasks[indexPath.row];
          } else {
              task = _highPriorityTasks[indexPath.row];
          }
          
          cell.textLabel.text = task.name;
          if([task.priority isEqualToString:@"low"]){
              cell.imageView.image = [UIImage imageNamed:@"lp"];
          }else if([task.priority isEqualToString:@"medium"]){
              cell.imageView.image = [UIImage imageNamed:@"mp"];
          }else if([task.priority isEqualToString:@"high"]){
              cell.imageView.image = [UIImage imageNamed:@"hp"];
          }
    }else{
        _task = _tasksInProgress[indexPath.row];
        cell.textLabel.text = _task.name;
        if([_task.priority isEqualToString:@"low"]){
            cell.imageView.image = [UIImage imageNamed:@"lp"];
        }else if([_task.priority isEqualToString:@"medium"]){
            cell.imageView.image = [UIImage imageNamed:@"mp"];
        }else if([_task.priority isEqualToString:@"high"]){
            cell.imageView.image = [UIImage imageNamed:@"hp"];
        }
    }
    
      return  cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Are you sure you want to delete this task?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteTaskAtIndexPath:indexPath];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:confirmAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)deleteTaskAtIndexPath:(NSIndexPath *)indexPath {
            if (_isFilter) {
                if (indexPath.section == 0) {
                    [_lowPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_tasksInProgress removeObjectAtIndex:indexPath.row];

                } else if (indexPath.section == 1) {
                    [_mediumPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_tasksInProgress removeObjectAtIndex:indexPath.row];

                } else {
                    [_highPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_tasksInProgress removeObjectAtIndex:indexPath.row];

                }
            } else {
                [_tasksInProgress removeObjectAtIndex:indexPath.row];
            }
            
            // Update UserDefaults
            NSError *error;
            NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_tasksInProgress requiringSecureCoding:YES error:&error];
            if (archiveData) {
                [[NSUserDefaults standardUserDefaults] setObject:archiveData forKey:@"tasksInProgress"];
            } else {
                NSLog(@"Error archiving data: %@", error);
            }
            
            [self.progressTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(_isFilter){
        if (section == 0) {
            return @"Low Priority";
        } else if (section == 1) {
            return @"Medium Priority";
        } else if (section == 2) {
            return @"High Priority";
        }
    }
    return nil;
}


- (void)getInTasks {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasksInProgress"];
        if (data) {
            NSError *error;
            NSArray *allowedClasses = @[NSArray.class, Task.class];
            NSArray<Task *> *unarchivedTasks = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:allowedClasses] fromData:data error:&error];
            
            if (unarchivedTasks) {
                if (_isFilter) {
                    NSMutableArray<Task *> *lowPriorityTasks = [NSMutableArray array];
                    NSMutableArray<Task *> *mediumPriorityTasks = [NSMutableArray array];
                    NSMutableArray<Task *> *highPriorityTasks = [NSMutableArray array];
                    
                    for (Task *task in unarchivedTasks) {
                        if ([task.priority isEqualToString:@"low"]) {
                            [lowPriorityTasks addObject:task];
                        } else if ([task.priority isEqualToString:@"medium"]) {
                            [mediumPriorityTasks addObject:task];
                        } else if ([task.priority isEqualToString:@"high"]) {
                            [highPriorityTasks addObject:task];
                        }
                    }
                    _lowPriorityTasks = lowPriorityTasks;
                    _mediumPriorityTasks = mediumPriorityTasks;
                    _highPriorityTasks = highPriorityTasks;
                } else {
                    _tasksInProgress = [unarchivedTasks mutableCopy];
                }
            } else {
                NSLog(@"Error decoding data: %@", error);
                // Handle error appropriately
                if (_isFilter) {
                    _lowPriorityTasks = [NSMutableArray array];
                    _mediumPriorityTasks = [NSMutableArray array];
                    _highPriorityTasks = [NSMutableArray array];
                } else {
                    _tasksInProgress = [NSMutableArray array];
                }
            }
        } else {
            if (_isFilter) {
                _lowPriorityTasks = [NSMutableArray array];
                _mediumPriorityTasks = [NSMutableArray array];
                _highPriorityTasks = [NSMutableArray array];
            } else {
                _tasksInProgress = [NSMutableArray array];
            }
        }
        [self.progressTable reloadData];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Task *selectedTask = _tasksInProgress[indexPath.row];
    NSError *error;
    NSData *taskArchiveData = [NSKeyedArchiver archivedDataWithRootObject:selectedTask requiringSecureCoding:YES error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:taskArchiveData forKey:@"selectedTask"];

    
    AddTaskViewController *add = [self.storyboard
    instantiateViewControllerWithIdentifier:@"task"];
    add.presentedFromAddButton = false;
    add.presentedFromProgress = true;
    add.presentedFromDone = false;
    add.presentFromTodo= false;
    add.indexofTaskProgress = indexPath.row;
    [self.navigationController pushViewController:add animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
