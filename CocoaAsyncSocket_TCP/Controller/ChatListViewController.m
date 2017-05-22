//
//  ChatListViewController.m
//  CocoaAsyncSocket_TCP
//
//  Created by 孟遥 on 2017/5/12.
//  Copyright © 2017年 mengyao. All rights reserved.
//


/*
 https://github.com/coderMyy/CocoaAsyncSocket_Demo  github地址 ,会持续更新关于即时通讯的细节 , 以及最终的UI代码
 
 https://github.com/coderMyy/MYCoreTextLabel  图文混排 , 实现图片文字混排 , 可显示常规链接比如网址,@,话题等 , 可以自定义链接字,设置关键字高亮等功能 . 适用于微博,微信,IM聊天对话等场景 . 实现这些功能仅用了几百行代码，耦合性也较低
 
 https://github.com/coderMyy/MYDropMenu  上拉下拉菜单，可随意自定义，随意修改大小，位置，各个项目通用
 
 https://github.com/coderMyy/MYPhotoBrowser 简易版照片浏览器。功能主要有 ： 点击点放大缩小 ， 长按保存发送给好友操作 ， 带文本描述照片，从点击照片放大，当前浏览照片缩小等功能。功能逐渐完善增加中.
 
 https://github.com/coderMyy/MYNavigationController  导航控制器的压缩 , 使得可以将导航范围缩小到指定区域 , 实现页面中的页面效果 . 适用于路径选择,文件选择等
 
 如果有好的建议或者意见 ,欢迎博客或者QQ指出 , 您的支持是对贡献代码最大的鼓励,谢谢. 求STAR ..😊😊😊
 */

#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "ChatHandler.h"
#import "ChatListCell.h"
#import "ChatModel.h"

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource,ChatHandlerDelegate>

@property (nonatomic ,strong)UITableView *chatlistTableView;
//消息数据源
@property (nonatomic, strong) NSMutableArray *messagesArray;

@end

@implementation ChatListViewController

- (NSMutableArray *)messagesArray
{
    if (!_messagesArray) {
        _messagesArray = [NSMutableArray array];
    }
    return _messagesArray;
}

- (UITableView *)chatlistTableView
{
    if (!_chatlistTableView) {
        _chatlistTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _chatlistTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _chatlistTableView.delegate         = self;
        _chatlistTableView.dataSource     = self;
        _chatlistTableView.rowHeight       = 60;
        //聊天列表cell
        [_chatlistTableView registerNib:[UINib nibWithNibName:@"ChatListCell" bundle:nil] forCellReuseIdentifier:@"ChatListCell"];
    }
    return _chatlistTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册成为消息分发对象之一
    [[ChatHandler shareInstance]addDelegate:self delegateQueue:nil];
    
    //UI
    [self initUI];
    
    //拉取数据库信息
    [self getMessages];
}



- (void)initUI
{
    [self.view addSubview:self.chatlistTableView];
}


#pragma mark - dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatListCell *listCell  = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    
    ChatModel *listModel = self.messagesArray[indexPath.row];
    
    listCell.chatModel = listModel;
    
    return listCell;
}

#pragma delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatModel *seletedChatModel = self.messagesArray[indexPath.row];
    ChatViewController *chatVc = [[ChatViewController alloc]init];
    chatVc.chatModel = seletedChatModel;
    [self.navigationController pushViewController:chatVc animated:YES];
}


#pragma mark - 接收消息代理
- (void)didReceiveMessage:(ChatModel *)chatModel type:(ChatMessageType)messageType
{
    
}

#pragma mark - 超时消息返回
- (void)sendMessageTimeOutWithTag:(long)tag
{
    
}


#pragma mark - 拉取数据库数据
- (void)getMessages
{
    //暂时先模拟假数据 , 后面加上数据库结构,再修改
    NSArray *tips = @[@"项目里IM这块因为一直都是在摸索,所以特别乱..",@"这一份相当于是进行重构,分层,尽量减少耦合性",@"还有就是把注释和大体思路尽量写下来",@"UI部分很耗时,因为所有的东西都是自己写的",@"如果有兴趣可以fork一下,有空闲时间我就会更新一些",@"如果觉得有用,麻烦star一下噢....",@"如果觉得有用,麻烦star一下噢....",@"具体IP端口涉及公司隐私东西已经隐藏....",@"具体IP端口涉及公司隐私东西已经隐藏...."];
    for (NSInteger index  = 0; index < 30; index ++) {
        
        ChatModel *chatModel   = [[ChatModel alloc]init];
        ChatContentModel *chatContent = [[ChatContentModel alloc]init];
        chatModel.content         = chatContent ;
        chatModel.toNickName  = @"孟遥";
        if (index<tips.count) {
            chatModel.lastMessage = tips[index];
        }else{
            chatModel.lastMessage  = @"模拟数据,UI部分持续更新中...涉及面较多,比较耗时";
        }
        chatModel.noDisturb      = index%3==0 ? @2 : @1;
        chatModel.unreadCount = @(index);
        chatModel.lastTimeString = [NSDate timeStringWithTimeInterval:chatModel.sendTime];
        [self.messagesArray addObject:chatModel];
    }
    
    [self configNav_Badges];
}

#pragma mark - 配置导航,tabbar角标
- (void)configNav_Badges
{
    NSUInteger totalUnread = 0;
    for (ChatModel *chatModel in self.messagesArray) {
        
        //如果不是免打扰(展示红点)的会话 , 计算总的未读数
        if (chatModel.noDisturb.integerValue !=2) {
            totalUnread += chatModel.unreadCount.integerValue ;
        }
    }
    self.title = totalUnread>0 ? [NSString stringWithFormat:@"%@(%li)",ChatlistTitle,totalUnread] : ChatlistTitle;
}



#pragma mark -  ---------大体思路罗列 
/*
 
                                                                以下思路 , 仅表个人意见 , 且是我能想到比较好的处理方法
 
                        =====================================================================================
                                                                                <<< 大致代码结构 >>>
 
                                                                                    GCDSocket
                                                                    (提供最原始的写入,读取,超时等方法)
                                                                       delegate : ChatHandler单例
                                                                     怎么去发送消息,接收消息的实际操作者
 
                                                                                         ||
                                                                                        ⏬
                                                                                    ChatHanlder
                            (作为中间业务逻辑处理层 , 主要将发送消息,接收消息和各个实际接收的控制器们连接起来,数据缓存,处理等)
                                    delegate : 需要接收消息的所有对象 (注册成为ChatHandler的代理,ChatHandler中数组对各个对象进行存储)
                                        数据处理(数据库以及沙盒),数据缓存(数据库以及沙盒),消息发送接收业务逻辑处理实际操作者
 
                                                ||                                          ||                                   ||
                                               ⏬                                        ⏬                                 ⏬
                                       ViewController1                     ViewController2                    .........
                                                            
                     控制器里需要做的 , 是对内存中消息模型进行操作 , 以此更新UI . 比如进度显示 , 失败红叹号显示 , 转圈 , 消息删除 , 撤回等 ...
 
 
                                                                                 这么设计的好处 :
                        1. 分工明确 , 每个控制器得到的消息 , 都是可以直接使用的 , 控制器只需要负责主要和V层进行交互 , 避免了在控制器中处理过多的逻辑
                        2. ChatHandler作为全局单例 , 生命周期和整个应用保持一致 . 而控制器 , 会随着用户操作而销毁 , 如果把数据放到控制器里处理 , 很可能会造成数据的丢失
 
                            =====================================================================================
                                                                                    <<< 关于缓存结构 >>>
                                                                            
                                    文本/表情消息             语音消息            图片消息            视频消息            文件消息        撤回消息        提示语消息
 
                                            ||                             ||                      ||                       ||                      ||                    ||                    ||
                                           ⏬                           ⏬                    ⏬                     ⏬                   ⏬                  ⏬                  ⏬
                                     数据库存储               数据库存储          数据库存储         数据库存储        数据库存储       数据库存储      数据库存储
                                                                          ||                       ||                       ||
                                                            沙盒缓存(语音data)  沙盒缓存(图片data) 沙盒缓存(视频)
 
 
                            ===================================================================================
 
 
 
 
 <<<<Socket连接>>>>
 
 登录 -> 连接服务器端口 -> 成功连接 -> SSL验证 -> 发送登录TCP请求(login) -> 收到服务端返回登录成功回执(loginReceipt) ->发送心跳 -> 出现连接中断 ->断网重连3次 -> 退出程序主动断开连接
 
 
 <<<<关于连接状态监听>>>>
 
 1. 普通网络监听
 
 由于即时通讯对于网络状态的判断需要较为精确 ，原生的Reachability实际上在很多时候判断并不可靠 。
 主要体现在当网络较差时，程序可能会出现连接上网络 ， 但并未实际上能够进行数据传输 。
 开始尝试着用Reachability加上一个普通的网络请求来双重判断实现更加精确的网络监听 ， 但是实际上是不可行的 。
 如果使用异步请求依然判断不精确 ， 若是同步请求 ， 对性能的消耗会很大 。
 最终采取的解决办法 ， 使用RealReachability ，对网络监听同时 ，PING服务器地址或者百度 ，网络监听问题基本上得以解决
 
 2. TCP连接状态监听：
 
 TCP的连接状态监听主要使用服务器和客户端互相发送心跳 ，彼此验证对方的连接状态 。
 规则可以自己定义 ， 当前使用的规则是 ，当客户端连接上服务器端口后 ，且成功建立SSL验证后 ，向服务器发送一个登陆的消息(login)。
 当收到服务器的登陆成功回执（loginReceipt)开启心跳定时器 ，每一秒钟向服务器发送一次心跳 ，心跳的内容以安卓端/iOS端/服务端最终协商后为准 。
 当服务端收到客户端心跳时，也给服务端发送一次心跳 。正常接收到对方的心跳时，当前连接状态为已连接状态 ，当服务端或者客户端超过3次（自定义）没有收到对方的心跳时，判断连接状态为未连接。
 
 
 
 
 <<<<关于本地缓存>>>>
 
 1. 数据库缓存
 
 建议每个登陆用户创建一个DB ，切换用户时切换DB即可 。
 搭建一个完善IM体系 ， 每个DB至少对应3张表 。
 一张用户存储聊天列表信息，这里假如它叫chatlist ，即微信首页 ，用户存储每个群或者单人会话的最后一条信息 。来消息时更新该表，并更新内存数据源中列表信息。或者每次来消息时更新内存数据源中列表信息 ，退出程序或者退出聊天列表页时进行数据库更新。后者避免了频繁操作数据库，效率更高。
 一张用户存储每个会话中的详细聊天记录 ，这里假如它叫chatinfo。该表也是如此 ，要么接到消息立马更新数据库，要么先存入内存中，退出程序时进行数据库缓存。
 一张用于存储好友或者群列表信息 ，这里假如它叫myFriends ，每次登陆或者退出，或者修改好友备注，删除好友，设置星标好友等操作都需要更新该表。
 
 2. 沙盒缓存
 
 当发送或者接收图片、语音、文件信息时，需要对信息内容进行沙盒缓存。
 沙盒缓存的目录分层 ，个人建议是在每个用户根据自己的userID在Cache中创建文件夹，该文件夹目录下创建每个会话的文件夹。
 这样做的好处在于 ， 当你需要删除聊天列表会话或者清空聊天记录 ，或者app进行内存清理时 ，便于找到该会话的所有缓存。大致的目录结构如下
 ../Cache/userID(当前用户ID)/toUserID(某个群或者单聊对象)/...（图片，语音等缓存）
 
 
 
 <<<<关于消息分发>>>>
 
 全局咱们设定了一个ChatHandler单例，用于处理TCP的相关逻辑 。那么当TCP推送过来消息时，我该将这些消息发给谁？谁注册成为我的代理，我就发给谁。
 ChatHandler单例为全局的，并且生命周期为整个app运行期间不会销毁。在ChatHandler中引用一个数组 ，该数组中存放所有注册成为需要收取消息的代理，当每来一条消息时，遍历该数组，并向所有的代理推送该条消息.
 
 
 
 
 
 <<<<聊天UI的搭建>>>>
 
 1. 聊天列表UI（微信首页）
 
 这个页面没有太多可说的 ， 一个tableView即可搞定 。需要注意的是 ，每次收到消息时，都需要将该消息置顶 。每次进入程序时，拉取chatlist表存储的每个会话的最后一条聊天记录进行展示 。
 
 2. 会话页面
 
 该页面tableView或者collectionView均可实现 ，看个人喜好 。这里是我用的是tableView .
 根据消息类型大致分为普通消息 ，语音消息 ，图片消息 ，文件消息 ，视频消息 ，提示语消息（以上为打招呼内容，xxx已加入群，xxx撤回了一条消息等）这几种 ，固cell的注册差不多为5种类型，每种消息对应一种消息。
 视频消息和图片消息cell可以复用 。
 不建议使用过少的cell类型 ，首先是逻辑太多 ，不便于处理 。其次是效率并不高。
 
 
 <<<<发送消息>>>>
 
 1. 文本消息/表情消息
 
 直接调用咱们封装好的ChatHandler的sendMessage方法即可 ， 发送消息时 ，需要存入或者更新chatlist和chatinfo两张表。若是未连接或者发送超时 ，需要重新更新数据库存储的发送成功与否状态 ，同时更新内存数据源 ，刷新该条消息展示即可。
 若是表情消息 ，传输过程也是以文本的方式传输 ，比如一个大笑的表情 ，可以定义为[大笑] ，当然规则自己可以和安卓端web端协商，本地根据plist文件和表情包匹配进行图文混排展示即可 。
 https://github.com/coderMyy/MYCoreTextLabel ，图文混排地址 ， 如果觉得有用 ， 请star一下 ，好人一生平安
 
 
 2. 语音消息
 
 语音消息需要注意的是 ，多和安卓端或者web端沟通 ，找到一个大家都可以接受的格式 ，转码时使用同一种格式，避免某些格式其他端无法播放，个人建议Mp3格式即可。
 同时，语音也需要做相应的降噪 ，压缩等操作。
 发送语音大约有两种方式 。
 一是先对该条语音进行本地缓存 ， 然后全部内容均通过TCP传输并携带该条语音的相关信息，例如时长，大小等信息，具体的你得测试一条压缩后的语音体积有多大，若是过大，则需要进行分割然后以消息的方法时发送。接收语音时也进行拼接。同时发送或接收时，对chatinfo和chatlist表和内存数据源进行更新 ，超时或者失败再次更新。
 二是先对该条语音进行本地缓存 ， 语音内容使用http传输，传输到服务器生成相应的id ，获取该id再附带该条语音的相关信息 ，以TCP方式发送给对方，当对方收到该条消息时，先去下载该条信息，并根据该条语音的相关信息进行展示。同时发送或接收时，对chatinfo和chatlist表和内存数据源进行更新 ，超时或者失败再次更新。
 
 
 3. 图片消息
 
 图片消息需要注意是 ，通过拍照或者相册中选择的图片应当分成两种大小 ， 一种是压缩得非常小的状态，一种是图片本身的大小状态。 聊天页面展示的 ，仅仅是小图 ，只有点击查看时才去加载大图。这样做的目的在于提高发送和接收的效率。
 同样发送图片也有两种方式 。
 一是先对该图片进行本地缓存 ， 然后全部内容均通过TCP传输 ，并携带该图片的相关信息 ，例如图片的大小 ，名字 ，宽高比等信息 。同样如果过大也需要进行分割传输。同时发送或接收时，对chatinfo和chatlist表和内存数据源进行更新 ，超时或者失败再次更新。
 二是先对该图片进行本地缓存 ， 然后通过http传输到服务器 ，成功后发送TCP消息 ，并携带相关消息 。接收方根据你该条图片信息进行UI布局。同时发送或接收时，对chatinfo和chatlist表和内存数据源进行更新 ，超时或者失败再次更新。
 
 4. 视频消息
 
 视频消息值得注意的是 ，小的视频没有太多异议，跟图片消息的规则差不多 。只是当你从拍照或者相册中获取到视频时，第一时间要获取到视频第一帧用于展示 ，然后再发送视频的内容。大的视频 ，有个问题就是当你选择一个视频时，首先做的是缓存到本地，在那一瞬间 ，可能会出现内存峰值问题 。只要不是过大的视频 ，现在的手机硬件配置完全可以接受的。而上传采取分段式读取，这个问题并不会影响太多。
 
 视频消息我个人建议是走http上传比较好 ，因为内容一般偏大 。TCP部分仅需要传输该视频封面以及相关信息比如时长，下载地址等相关信息即可。接收方可以通过视频大小判断，如果是小视频可以接收到后默认自动下载，自动播放 ，大的视频则只展示封面，只有当用户手动点击时才去加载。具体的还是需要根据项目本身的设计而定。
 
 5. 文件消息
 
 文件方面 ，iOS端并不如安卓端那种可操作性强 ,安卓可以完全获取到用户里的所有文件，iOS则有保护机制。通常iOS端发送的文件 ，基本上仅仅局限于当前app自己缓存的一些文件 ，原理跟发送图片类似。
 
 6. 撤回消息
 
 撤回消息也是消息内容的一种类型 。例如 A给B发送了一条消息 "你好" ，服务端会对该条消息生成一个messageID ，接收方收到该条消息的messageID和发送方的该条消息messageID一致。如果发送端需要撤回该条消息 ，仅仅需要拿到该条消息messageID ，设置一下消息类型 ，发送给对方 ，当收到撤回消息的成功回执(repealReceipt)时，移除该会话的内存数据源和更新chatinfo和chatlist表 ，并加载提示类型的cell进行展示例如“你撤回了一条消息”即可。接收方收到撤回消息时 ，同样移除内存数据源 ，并对数据库进行更新 ，再加载提示类型的cell例如“张三撤回了一条消息”即可。
 
 7. 提示语消息
 
 提示语消息通常来说是服务器做的事情更多 ，除了撤回消息是需要客户端自己做的事情并不多。
 当有人退出群 ，或者自己被群主踢掉 ，时服务端推送一条提示语消息类型，并附带内容，客户端仅仅需要做展示即可，例如“张三已经加入群聊”，“以上为打招呼内容”，“你已被踢出该群”等。
 当然 ，撤回消息也可以这样实现 ，这样提示消息类型逻辑就相当统一，不会显得很乱 。把主要逻辑交于了服务端来实现。
 
 
 <<<<消息删除>>>>
 
 这里需要注意的一点是 ，类似微信的长按消息操作 ，我采用的是UIMenuController来做的 ，实际上有一点问题 ，就是第一响应者的问题 ，想要展示该menu ，必须将该条消息的cell置为第一响应者，然后底部的键盘失去第一响应者，会降下去 。所以该长按出现menu最好还是自定义 ，根据计算相对frame进行布局较好，自定义程度也更好。
 
 消息删除大概分为删除该条消息 ，删除该会话 ，清空聊天记录几种
 删除该条消息仅仅需要移除本地数据源的消息模型 ，更新chatlist和chatinfo表即可。
 删除该会话需要移除chatlist和chatinfo该会话对应的列 ，并根据当前登录用户的userID和该会话的toUserID或者groupID移除沙盒中的缓存。
 清空聊天记录，需要更新chatlist表最后一条消息内容 ，删除chatinfo表，并删除该会话的沙盒缓存.
 
 
 <<<<消息拷贝>>>>
 
 这个不用多说 ，一两句话搞定
 
 
 <<<<消息转发>>>>
 
 拿到该条消息的模型 ，并创建新的消息 ，把内容赋值到新消息 ，然后选择人或者群发送即可。
 
 值得注意的是 ，如果是转发图片或者视频 ，本地沙盒中的缓存也应当copy一份到转发对象所对应的沙盒目录缓存中 ，不能和被转发消息的会话共用一张图或者视频 。因为比如 ：A给B发了一张图 ，A把该图转发给了C ，A移除掉A和B的会话 ，那么如果是共用一张图的话 ，A和C的会话中就再也无法找到这张图进行展示了。
 
 
 <<<<重新发送>>>>
 
 这个没有什么好说的。
 
 
 <<<<标记已读>>>>
 
 功能实现比较简单 ，仅仅需要修改数据源和数据库的该条会话的未读数（unreadCount），刷新UI即可。
 
 
 
 <<<<以下为大致的实现步骤>>>>
 
 文本/表情消息 ：
 
 方式一： 输入 ->发送 -> 消息加入聊天数据源 -> 更新数据库 -> 展示到聊天会话中 -> 调用TCP发送到服务器（若超时，更新聊天数据源，更新数据库 ，刷新聊天UI） ->收到服务器成功回执(normalReceipt) ->修改数据源该条消息发送状态(isSend) -> 更新数据库
 方式二： 输入 ->发送 -> 消息加入聊天数据源 -> 展示到聊天会话中 -> 调用TCP发送到服务器（若超时，更新聊天数据源，刷新聊天UI） ->收到服务器成功回执(normalReceipt) ->修改数据源该条消息发送状态(isSend) ->退出app或者页面时 ，更新数据库
 
 
 语音消息 ：（这里以http上传，TCP原理一致）
 
 方式一： 长按录制 ->压缩转格式 -> 缓存到沙盒 -> 更新数据库->展示到聊天会话中，展示转圈发送中状态 -> 调用http分段式上传(若失败，刷新UI展示) ->调用TCP发送该语音消息相关信息（若超时，刷新聊天UI） ->收到服务器成功回执 -> 修改数据源该条消息发送状态(isSend) ->修改数据源该条消息发送状态(isSend)-> 更新数据库-> 刷新聊天会话中该条消息UI
 方式二： 长按录制 ->压缩转格式 -> 缓存到沙盒 ->展示到聊天会话中，展示转圈发送中状态 -> 调用http分段式上传（若失败，更新聊天数据源，刷新UI展示） ->调用TCP发送该语音消息相关信息（若超时,更新聊天数据源，刷新聊天UI） ->收到服务器成功回执 -> 修改数据源该条消息发送状态(isSend -> 刷新聊天会话中该条消息UI - >退出程序或者页面时进行数据库更新
 
 
 图片消息 ：（两种考虑，一是展示和http上传均为同一张图 ，二是展示使用压缩更小的图，http上传使用选择的真实图片，想要做到精致，方法二更为可靠）
 
 方式一： 打开相册选择图片 ->获取图片相关信息，大小，名称等，根据用户是否选择原图，考虑是否压缩 ->缓存到沙盒 -> 更新数据库 ->展示到聊天会话中，根据上传显示进度 ->http分段式上传(若失败，更新聊天数据,更新数据库,刷新聊天UI) ->调用TCP发送该图片消息相关信息（若超时，更新聊天数据源，更新数据库,刷新聊天UI）->收到服务器成功回执 -> 修改数据源该条消息发送状态(isSend) ->更新数据库 -> 刷新聊天会话中该条消息UI
 方式二：打开相册选择图片 ->获取图片相关信息，大小，名称等，根据用户是否选择原图，考虑是否压缩 ->缓存到沙盒 ->展示到聊天会话中，根据上传显示进度 ->http分段式上传(若失败，更细聊天数据源 ，刷新聊天UI) ->调用TCP发送该图片消息相关信息（若超时，更新聊天数据源 ，刷新聊天UI）->收到服务器成功回执 -> 修改数据源该条消息发送状态(isSend) -> 刷新聊天会话中该条消息UI ->退出程序或者离开页面更新数据库
 
 视频消息：
 
 方式一：打开相册或者开启相机录制 -> 压缩转格式 ->获取视频相关信息，第一帧图片，时长，名称，大小等信息 ->缓存到沙盒 ->更新数据库 ->第一帧图展示到聊天会话中，根据上传显示进度 ->http分段式上传(若失败，更新聊天数据,更新数据库,刷新聊天UI) ->调用TCP发送该视频消息相关信息（若超时，更新聊天数据源，更新数据库,刷新聊天UI）->收到服务器成功回执 -> 修改数据源该条消息发送状态(isSend) ->更新数据库 -> 刷新聊天会话中该条消息UI
 方式二：打开相册或者开启相机录制 ->压缩转格式 ->获取视频相关信息，第一帧图片，时长，名称，大小等信息 ->缓存到沙盒 ->第一帧图展示到聊天会话中，根据上传显示进度 ->http分段式上传(若失败，更细聊天数据源 ，刷新聊天UI) ->调用TCP发送该视频消息相关信息（若超时，更新聊天数据源 ，刷新聊天UI）->收到服务器成功回执 -> 修改数据源该条消息发送状态(isSend) -> 刷新聊天会话中该条消息UI ->退出程序或者离开页面更新数据库
 
 文件消息：
 跟上述一致 ，需要注意的是，如果要实现该功能 ，接收到的文件需要在沙盒中单独开辟缓存。比如接收到web端或者安卓端的文件
 
 
 <<<<消息丢失问题>>>>
 
 消息为什么会丢失 ？
 最主要原因应该归结于服务器对客户端的网络判断不准确。尽管客户端已经和服务端建立了心跳验证 ， 但是心跳始终是有间隔的，且TCP的连接中断也是有延迟的。例如，在此时我向服务器发送了一次心跳，然后网络失去了连接，或者网络信号不好。服务器接收到了该心跳 ，服务器认为客户端是处于连接状态的，向我推送了某个人向我发送的消息 ，然而此时我却不能收到消息，所以出现了消息丢失的情况。
 
 补充: CocoaSyncSocket的三次握手四次挥手验证,仅仅表现在连接时确保可靠的连接和断开 ,而并不能保证消息数据传输中的可靠性 , 所以消息数据传输,我们可以模拟三次握手进行传输.
 
 解决办法 ：客户端向服务端发送消息，服务端会给客户端返回一个回执，告知该条消息已经发送成功。所以，客户端有必要在收到消息时，也向服务端发送一个回执，告知服务端成功收到了该条消息。而客户端，默认收到的所有消息都是离线的，只有收到客户端的接收消息的成功回执后，才会移除掉该离线消息缓存，否则将会把该条消息以离线消息方式同步推送。离线消息后面会做解释。此时的双向回执，可以把消息丢失概率降到非常低 ,基本上算是模拟了一个消息数据传输的三次握手。
 
 
 <<<<消息乱序问题>>>>
 
 消息为什么会乱序 ？
 客户端发送消息，该消息会默认赋值当前时间戳 ，收到安卓端或者web端发来的消息时，该时间戳是安卓和web端获取，这样就可能会出现时间戳的误差情况。比如当前聊天展示顺序并没有什么问题，因为展示是收到一条展示一条。但是当退出页面重新进入时，如果拉取数据库是根据时间戳的降序拉取 ，那么就很容易出现混乱。
 解决办法 ：表结构设置自增ID ，消息的顺序展示以入库顺序为准 ，拉取数据库获取消息记录时，根据自增ID降序拉取 。这样就解决了乱序问题 ，至少保证了，展示的消息顺序和我聊天时的一样。尽管时间戳可能并不一样是按照严谨的降序排列的。
 
 <<<<离线消息>>>>
 进入后台，接收消息提醒:
 解决方式要么采用极光推送进行解决 ，要么让自己服务器接苹果的服务器也行。毕竟极光只是作为一个中间者，最终都是通过苹果服务器推送到每个手机。
 
 进入程序加载离线消息：此处需要注意的是，若服务器仅仅是把每条消息逐个推送过来，那么客户端会出现一些小问题，比如角标数为每次增加1，最后一条消息不断更新 ，直到离线消息接收到完毕，造成一种不好的体验。
 解决办法：离线消息服务端全部进行拼接或者以jsonArray方式，并协议分割方式，客户端收到后仅需仅需切割，直接在角标上进行总数的相加，并直接更新最后一条消息即可。亦或者，设置包头信息，告知每条消息长度，切割方式等。
 
 <<<<版本兼容性问题处理>>>>
 其实 , 做IM遇到最麻烦的问题之一 , 就应当是版本兼容问题 . 即时通讯的功能点有很多 , 项目不可能一期所有的功能全部做完 , 那么就会涉及到新老版本兼容的问题 . 当然如果服务端经验足够丰富 , 版本兼容的问题可以交于服务端来完成 , 客户端并不需要做太多额外的事情 . 如果是并行开发 , 服务端思路不够长远 ,或者产品需求变更频繁且比较大.那么客户端也需要做一些相应的版本兼容问题 . 处理版本兼容问题并不难 , 主要问题在于当增加一个新功能时 , 服务端或许会推送过来更多的字段 , 而老版本的项目数据库如果没有预留足够的字段 , 就涉及到了数据库升级 . 而当收到高版本新功能的消息时 , 客户端也应当对该消息做相应的处理 . 例如,老版本的app不支持消息撤回 , 而新版本支持消息撤回 , 当新版本发送消息撤回时 , 老版本可以拦截到这条未知的消息类型 , 做相应的处理 , 比如替换成一条提示"该版本暂不支持,请前往appstore下载新版本"等. 而当必要时 , 如果整个IM结构没有经过深思熟虑 , 还可能会涉及到强制升级 .
 
 <<<<[有人@你]>>>>
 对于 有人@你 这个功能的实现可分为2部分 :
 1. 聊天列表最后一条消息前展示[有人@你] ,例如 [有人@你]你好 . 因为有人@你这个功能只出现在群组中 ,所以在发送消息时 ,设立"toUser"字段即可,当然这个字段名可以自己设定,当发送端@多个人时,自己定义规则进行拼接(安卓端,iOS端,web端协商),例如@"userID1,userID2,userID3"则表明了我@了这三个人.
 当接收端接收到toUser字段不为空时,切割遍历userID是否有自己的id即可.如果有,说明有人@我 ,偏好设置userdefault进行存储状态即可 .进入该条会话,清除userdefault .
 
 2. 聊天对话页的锚点展示 , 具体什么时候展示锚点,微信的逻辑大概是:
 当一个群处于正常状态下,有人@我 ,右上角展示 "有人@我"按钮,点击按钮拉取所有的未读消息,这里是未读消息,而不是定位到"有人@我"那一条 . 若没有人@我,则展示"未读消息"按钮 , 定位也是到第一条未读消息位置
 
 当一个群处于免打扰状态下,有人@我,右上角展示"有人@你"按钮 , 点击按钮 ,定位到 "有人@我"那一条.
 
 这里我的做法是 , 直接拉取数据库从 "有人@你" 或者所有的未读消息到最新的一条消息间的所有消息, 这样做法对于用户量不是特别大的情况下 , 不会出现任何问题.若是消息数量特别庞大 , 几千甚至上万条 ,该做法就不适用了,拉取的数据过多,解决办法可以借鉴微信做法 , 定位时获取中间一段消息,然后进行上拉或者下拉再去类似分页的去拉取数据库.
 
 <<<<[草稿]功能>>>>
 草稿功能相对简单 ,跟 "有人@你" 展示逻辑差不多 , 当退出聊天会话页时,检查一下键盘输入框中是否有值 , 有值则userdefault存入该信息和对应的该条会话的userID或者groupID.聊天页面展示时,判断一下该条会话是否有草稿,如果有展示 . 进入聊天会话页时,也检查一次是否有草稿 ,如果有,自动弹起键盘,填充上次的内容即可.
 
 <<<<注意事项>>>>
 1. 在搭建体系时 , 尽量把数据和业务逻辑都抽取到ChatHandler中 , 控制器里只需要拿到直接可用的消息模型即可 . 不然后期功能增多 , 控制器里的逻辑和代码会越来越多 ,并且还需要考虑控制器的生命周期问题 , 比较麻烦
 
 以上仅为大体的思路 , 实际上搭建IM , 更多的难点在于逻辑的处理和各种细节问题 . 比如数据库,本地缓存,和服务端的通信协议,和安卓端私下通信协议.以及聊天UI的细节处理,例如聊天背景实时拉高,图文混排等等一系列麻烦的事.没办法写到很详细 ,都需要自己仔细的去思考.难度并不算很大,只是比较费心.
 
 
 
 写在最后 :
 
 其实上述的思路什么的 , 也许看的时候并不觉得复杂 , 但是实际上真正去搭建时 , 其中遇到的各种问题还是非常的恶心 ,直到功能全部做完 ,才对整体有了一个比较全面的认识 . 还有就是很多人在求UI方面的代码 , 由于最近一直在抽时间学习java方面的东西 , UI的东西我会尽快的补上来 ,UI不难 ,难的是UI串起来的逻辑和细节 ...
 
 */

@end
