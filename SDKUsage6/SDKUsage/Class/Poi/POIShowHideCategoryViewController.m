//
//  POIShowHideCategoryViewController.m
//  SDKUsage
//
//  Created by BIM on 2017/10/16.
//  Copyright © 2017年 BIM. All rights reserved.
//

#import "POIShowHideCategoryViewController.h"

#import "MAStateManager.h"
#import "MAMapView.h"
#import "MAFloorInfo.h"
#import "DropdownMenu.h"
#import "MAVector.h"

#define kCameraAlgneMin 15.0f
#define kCameraAlgneMax 95.0f
@interface POIShowHideCategoryViewController ()<DropdownMenuDelegate,UIGestureRecognizerDelegate,MADelegate>{
    
    CGFloat _origional;
}
@property (nonatomic,strong)MAManager *manager;
@property (nonatomic,copy)NSString *url;
@property (nonatomic,assign)int prjId;
@property (nonatomic,strong)NSArray *floorinfoArray;

@property (nonatomic,strong)DropdownMenu *changeFloorMenu;
@property (nonatomic,strong)DropdownMenu *changeBackColorMenu;
@end

@implementation POIShowHideCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"POI按分类显示隐藏";
    [self addPanChange2Dto3D];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    if (_manager == nil) {
        [self mapConfiguration];
    }
    
    [self setUpSubviews];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self onExit_Clicked:nil];
    
}

- (void)onExit_Clicked:(id)sender
{
    // 맵 데이터 삭제 후, 사용하면 안됨.
    
    
    [_manager clearData];
    [[_manager getMapView] removeFromSuperview];
    [_manager clearMap];
}

#pragma mark 2Dto3D
- (void)addPanChange2Dto3D{
    _origional = 1;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDown:)];
    panGesture.minimumNumberOfTouches = 3;
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
}
-(void)panGestureDown:(UIPanGestureRecognizer*)sender{
    
    
    
    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
        UIPanGestureRecognizerDirectionUndefined,
        UIPanGestureRecognizerDirectionUp,
        UIPanGestureRecognizerDirectionDown,
        UIPanGestureRecognizerDirectionLeft,
        UIPanGestureRecognizerDirectionRight
    };
    
    
    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            
            if (direction == UIPanGestureRecognizerDirectionUndefined) {
                CGPoint velocity = [sender velocityInView:self.view];
                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = UIPanGestureRecognizerDirectionDown;
                    } else {
                        direction = UIPanGestureRecognizerDirectionUp;
                    }
                }
                else {
                    if (velocity.x > 0) {
                        direction = UIPanGestureRecognizerDirectionRight;
                    } else {
                        direction = UIPanGestureRecognizerDirectionLeft;
                    }
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            
            switch (direction) {
                case UIPanGestureRecognizerDirectionUp: {
                    
                    
                    if (_origional < 1) {
                        _origional += 0.04;
                        float ANGLE = (_origional * (kCameraAlgneMax - kCameraAlgneMin)) + kCameraAlgneMin;
                        NSLog(@"CAMERA ANGLE : %f",ANGLE);
                        
                        if ((kCameraAlgneMax >= ANGLE && ANGLE >= kCameraAlgneMin)) {
                            [_manager setCameraAngle:ANGLE];
                        }
                    }
                    break;
                }
                case UIPanGestureRecognizerDirectionDown: {
                    
                    if (_origional > 0) {
                        _origional -= 0.04;
                        float ANGLE = (_origional * (kCameraAlgneMax - kCameraAlgneMin)) + kCameraAlgneMin;
                        NSLog(@"CAMERA ANGLE : %f",ANGLE);
                        
                        if ((kCameraAlgneMax >= ANGLE && ANGLE >= kCameraAlgneMin)) {
                            [_manager setCameraAngle:ANGLE];
                        }
                    }
                    
                    break;
                }
                    
                default: {
                    break;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            NSLog(@"end");
            // 记录结束滑动位置
            NSLog(@"%f ====  "  ,_origional);
            direction = UIPanGestureRecognizerDirectionUndefined;
            
            
            float ANGLE = (_origional * (kCameraAlgneMax - kCameraAlgneMin)) + kCameraAlgneMin;
            NSLog(@"CAMERA ANGLE : %f",ANGLE);
            
            if ((kCameraAlgneMax >= ANGLE && ANGLE >= kCameraAlgneMin)) {
                [_manager setCameraAngle:ANGLE];
            }
            break;
        }
        default:
            break;
    }
    
    
}
#pragma mark 添加子控件
- (void)setUpSubviews{
    [self addChangeFloorMenu];
    [self addChangeBackColorMenu];
    
}
- (void)addChangeFloorMenu{
    DropdownMenu * dropdownMenu = [[DropdownMenu alloc] init];
    [dropdownMenu setFrame:CGRectMake(20, UIScreen.mainScreen.bounds.size.height - 50, 100, 40)];
    dropdownMenu.delegate = self;
    self.changeFloorMenu = dropdownMenu;
    NSArray *floorinfoA = [_manager getFloorInfo:[[_manager getCurrentBuildingId]intValue ]];
    self.floorinfoArray = floorinfoA;
    NSLog(@"floorinfoA == %@  \n",floorinfoA);
    
    for (MAFloorInfo *foolInfo in floorinfoA) {
        NSLog(@"foolInfo.floor_id===  %@",foolInfo.floor_id);
    }
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < floorinfoA.count; i++) {
        NSString *string = [NSString stringWithFormat:@"第%zd层",i];
        [arrayM addObject:string];
    }
    [dropdownMenu setMenuTitles:arrayM rowHeight:30];
    [self.view addSubview:dropdownMenu];
    
}

- (void)addChangeBackColorMenu{
    DropdownMenu * dropdownMenu = [[DropdownMenu alloc] init];
    [dropdownMenu setFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width - 150, UIScreen.mainScreen.bounds.size.height - 50, 100, 40)];
    dropdownMenu.delegate = self;
    self.changeBackColorMenu = dropdownMenu;
    NSArray *array = @[@"显示",@"隐藏"];
    [dropdownMenu.mainBtn setTitle:@"POI" forState:UIControlStateNormal];
    [dropdownMenu setMenuTitles:array rowHeight:30];
    [self.view addSubview:dropdownMenu];
    
}
#pragma mark 初始化

- (void)mapConfiguration{
    if (_manager == nil) {
        [self mapSetting];
    }
    
}
- (void)mapSetting{
    self.url = baseUrl;
    self.prjId = VBMapProjtectId;
    
    self.manager = [[MAManager alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.manager getMapView].frame = CGRectMake(0, 32, self.view.frame.size.width, self.view.frame.size.height - 40 - 65);
    [self.manager setBackgroundColorWithRed:144.0 green:165.0 blue:180.0];
    
    [self.view addSubview:[_manager getMapView]];
    
    [_manager setServerUrl:_url];
    [_manager setProjectId:_prjId];
    [_manager debugEnable:YES];
   // [SVProgressHUD showInfoWithStatus:@"初始化成功"];
    
    _manager.delegate = self;
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    MAStateManager *stateManager = [MAStateManager Instance];
    stateManager.current_project_id = _prjId;
    stateManager.downloadPath = documentPath;
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self onLoadMap_Clicked:nil];
    //    });
    [self onLoadMap_Clicked:nil];
    [_manager updatePanBoundAsAABB];
    
}

- (void)onLoadMap_Clicked:(id)sender
{
    
    [_manager loadMap:[[_manager getDefaultBuildingId] intValue] floorId:[_manager getDefaultFloorId]];
    
    
    MAMapView *map = (MAMapView *)[_manager getMapView];
    
    MAVector *vector = [_manager getMapPointX:[UIScreen mainScreen].bounds.size.width * 0.5 andY:[UIScreen mainScreen].bounds.size.height * 0.5];
    //[_manager mapMoveTo:vector];
    // [map mapCenterAsPx:3000.0f Py:0.0f Pz:10000.0f];
    [map mapCenterAsPx:vector.x  Py:vector.y Pz:vector.z];
    [_manager setZoom:22000.0];
    
    [_manager showPoi:YES];
    
    
}


#pragma mark MADelegate
- (void)onReadyForUpdate{
    [_manager  needUpdate:_prjId];
    //[_manager startUpdate];
}

-(void)onNeedUpdate:(BOOL)update
{
    if (update == YES) {
        [_manager startUpdate];
    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update" message:@"它是最新的文件." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
    }
}
// 必须有
-(void)onUpdateStateChanged:(MAUpdate*)update
{
    switch([update getState])
    {
        case MA_DOWNLOADING:
            // labelProgress.text = [NSString stringWithFormat:@"Download:%d%%", update.progress];
            break;
            
        case MA_SUCCESS:
            break;
            
            // 업데이트 실패가 호출된 후, 라이브러리에서 해당 프로젝트에 해당하는 데이터를 지우지 않고, 앱에서 해당 데이터를 삭제함.
        case MA_FAILED:
            if ([_manager isExistProjectData:_prjId]) {
                [_manager deleteProjectData:_prjId];
            }
            break;
        default:
            NSAssert(NO,@"정의되지 않은 상태.");
            break;
    }
}
#pragma mark - Map Loading

- (void)onMapLoadingSuccess
{
    
    [_manager refresh];
    return;
    
}
- (void)onNetworkFailed
{
    NSLog(@"onNetworkFailed");
}
- (void)onMapLoadingFailed
{
    //[ActivityWindow Hide];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading" message:@"Map Loading Failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark DropdownMenu Delegate  选择楼层
- (void)dropdownMenu:(DropdownMenu *)menu selectedCellNumber:(NSInteger)number{
    NSLog(@"你选择了：%ld",number);
    [_manager setPoiTextSize:20];
    [_manager setPoiTextColor:[UIColor redColor]];
   
    if (menu == self.changeBackColorMenu) {
        NSLog(@"是否显示POI");
        if (0 == number) {// 鸟瞰
            [_manager showPoi:YES];
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
            [array addObject:[NSNumber numberWithInt:18]];
            [_manager setShowPoiType:array];
            NSArray *categoryA = [_manager getPoiCategory];
            NSArray *cate = [_manager getCategoryList:[NSString stringWithFormat:@"%zd",_prjId]];
            NSLog(@"categoryA====  %@  cate==  %@"  ,categoryA,cate);
            
        }else if (1 == number){ // 顶部
            [_manager showPoi:NO];
            
        }
    }else{
        NSLog(@"改变楼层");
        
        [_manager showPoi:YES];
        [_manager loadMapAll:[[_manager getDefaultBuildingId]intValue]];
        MAFloorInfo *floorInfo = self.floorinfoArray[number];
        [_manager changeFloorById:floorInfo.floor_id];
     
        
        NSArray *poiA = [_manager getPoiInfoListByFloorId:floorInfo.floor_id];
        // MAPoi *poi = poiA[0];
        // poi.visible = YES;
        // [_manager changePoiIcon:poi.poi_id name:@"show.png"];
        
        NSLog(@"poiA===  %@",poiA);
        
    }
    
    
}


@end


