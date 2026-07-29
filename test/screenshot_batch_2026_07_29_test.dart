import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_guardian/src/import/cart_screenshot_importer.dart';
import 'package:shopping_guardian/src/import/share_parser.dart';

void main() {
  group('2026-07-29 supplied product screenshots', () {
    test('Pinduoduo coupon-priced scale stand', () {
      final item = _single([
        '券后¥2.99 优惠5元',
        '已拼8500件',
        '先用后付',
        '适用小米体脂体重称支架落地款支架体重秤收纳',
        '近30天新增3027条好评，全店1665人在拼',
        '直接拼成',
        '免拼购买',
      ]);

      expect(item.platform, ShoppingPlatform.pinduoduo);
      expect(item.price, 2.99);
      expect(item.title, contains('体重秤收纳'));
    });

    test('Pinduoduo multi-line snack title', () {
      final item = _single([
        '券后¥12',
        '秒杀价¥12.7',
        '已拼833件',
        '百亿补贴',
        '店铺 收藏 客服百A贴品牌三只松鼠]【三只松鼠】烤椰子味压',
        '缩饼干420g代餐饱腹粗粮干粮户外充饥抗饿零食',
        '全店1566人在拼，同类畅销第2名',
        '直接拼成',
      ]);

      expect(item.price, 12);
      expect(item.title, contains('三只松鼠'));
      expect(item.title, contains('抗饿零食'));
      expect(item.title, isNot(contains('店铺')));
    });

    test('Pinduoduo drops a split navigation block from the final title', () {
      final item = _single([
        '券后¥12',
        '秒杀价¥12.7',
        '已拼833件',
        '百亿补贴',
        '店铺 收藏 客服百A贴品牌',
        '三只松鼠]【三只松鼠】烤椰子味压缩饼干420g',
        '代餐饱腹粗粮干粮户外充饥抗饿零食',
        '全店1566人在拼，同类畅销第2名',
        '直接拼成',
      ]);

      expect(item.price, 12);
      expect(item.title, contains('三只松鼠'));
      expect(item.title, contains('抗饿零食'));
      expect(item.title, isNot(contains('店铺')));
      expect(item.title, isNot(contains('客服')));
    });

    test('Pinduoduo regular-price chips', () {
      final item = _single([
        '¥29.9',
        '已抢1060包·快要抢光',
        '官方旗舰',
        '品牌 上好佳 官方旗舰',
        '上好佳X老干妈薯片风味豆豉',
        '膨化休闲小零食80g【8月5日发完】',
        '近7天品牌疯抢5万件，全店977人在拼',
        '直接拼成',
        '免拼购买',
      ]);

      expect(item.price, 29.9);
      expect(item.title, contains('上好佳X老干妈'));
      expect(item.title, contains('80g'));
    });

    test('Pinduoduo subsidy-priced charging cable', () {
      final item = _single([
        '补贴价¥19.7 ¥25.9',
        '官方补贴6.2元',
        '已拼1763件',
        '百亿补贴',
        '品牌 海备思',
        '【海备思】typec双L弯头充',
        '电数据线磁吸充电宝PD240W快充适用iPhone17',
        '直接拼成',
        '免拼购买',
      ]);

      expect(item.price, 19.7);
      expect(item.title, contains('海备思'));
      expect(item.title, contains('PD240W'));
    });

    test('Taobao video detail lamp', () {
      final item = _single([
        '平台加补后¥175起 | 优惠前¥228起',
        '官方立减12%省28元',
        '已售 1000+',
        '极有家 栖宋 光轴日落台灯中古床头灯包豪斯乔迁',
        '礼物桌面摆件复古氛围灯',
        '加入购物车',
        '领券购买',
      ]);

      expect(item.platform, ShoppingPlatform.taobao);
      expect(item.price, 175);
      expect(item.title, contains('光轴日落台灯'));
      expect(item.title, contains('复古氛围灯'));
    });

    test('Taobao video detail monitor stand', () {
      final item = _single([
        '平台加补后¥88.56起 | 优惠前¥122起',
        '天降礼金减16元',
        '全网热销1000+',
        '全网热銷1000+ 0',
        '灯带+PD',
        'ADA/KQJ! KONP。',
        '组合套装推荐搭配清单',
        '天猫 电脑显示器增高架透明台式电脑支架托桌面',
        '@e**瓶：细节把控真的...',
        '悬空收纳办公室工位氛围感带灯置物电..',
        '一键送礼',
        '平台加补后¥88.56起',
        '去购买',
      ]);

      expect(item.platform, ShoppingPlatform.taobao);
      expect(item.price, 88.56);
      expect(item.title, contains('电脑显示器增高架'));
      expect(item.title, isNot(contains('送礼')));
      expect(item.title, isNot(contains('细节把控')));
      expect(item.title, isNot(contains('礼金')));
      expect(item.title, isNot(contains('灯带+PD')));
      expect(item.title, isNot(contains('ADA/KQJ')));
      expect(item.title, isNot(contains('组合套装')));
    });

    test('Taobao video detail keyboard cable', () {
      final item = _single([
        '平台加补后¥37 | 优惠前¥49',
        '已售 5000+',
        '天猫 VKP微控派星曜8k航插线磁轴机械键盘线可',
        '调发光线RGB灯不断触',
        '平台加补后¥37',
        '去购买',
      ]);

      expect(item.platform, ShoppingPlatform.taobao);
      expect(item.price, 37);
      expect(item.title, contains('VKP微控派'));
      expect(item.title, contains('RGB灯不断触'));
    });

    test('Taobao compact product card', () {
      final item = _single([
        'VKP数码旗舰店',
        '¥37 已优惠12元',
        '天猫 VKP微控派星曜键盘航插线 详情',
        '已售5000+',
        '加入购物车',
        '立即购买',
      ]);

      expect(item.platform, ShoppingPlatform.taobao);
      expect(item.price, 37);
      expect(item.title, 'VKP微控派星曜键盘航插线 详情');
    });

    test('JD nail-tool detail', () {
      final item = _single([
        '¥19.9',
        '¥29.9 日常价 | 已售6000+',
        '可再享：小金库支付减2元',
        '小天籁（XIAO TIAN LAI）指甲刀全套指甲剪工具',
        '包指甲钳修脚刀挖耳勺鼻毛剪指甲套装工',
        '加入购物车',
        '立即购买',
      ]);

      expect(item.platform, ShoppingPlatform.jd);
      expect(item.price, 19.9);
      expect(item.title, contains('小天籁'));
      expect(item.title, contains('鼻毛剪'));
    });

    test('JD PLUS-priced nail clipper', () {
      final item = _single([
        '¥25.56 PLUS到手价',
        '¥26.9 补贴价 | 已售3万+',
        '自营 京东超市',
        '贝印日本进口全钢指甲钳/指甲刀剪',
        '单把 防飞溅 001系列 小号（S）',
        '加入购物车',
        '立即购买',
      ]);

      expect(item.platform, ShoppingPlatform.jd);
      expect(item.price, 25.56);
      expect(item.title, contains('贝印日本进口'));
      expect(item.title, contains('小号（S）'));
    });

    test('JD compact product card', () {
      final item = _single([
        '预估到手价：¥4399',
        '¥4377.01到手价 ¥4399',
        '销量1万+',
        '自营 联想（ThinkCentre）Q500',
        '加入购物车',
        '立即购买',
      ]);

      expect(item.platform, ShoppingPlatform.jd);
      expect(item.price, 4377.01);
      expect(item.title, '联想（ThinkCentre）Q500');
    });

    test('JD government-subsidy router', () {
      final item = _single([
        '¥711.55 政府补贴价 ¥749',
        '已售400+',
        'GLINET MT5000有线路由器 软路由交换机企业',
        '旁路由 千兆智能迷你网关QOS 2.5G端口U',
        '加入购物车',
        '补贴后¥711.55',
      ]);

      expect(item.platform, ShoppingPlatform.jd);
      expect(item.price, 711.55);
      expect(item.title, contains('GLINET MT5000'));
      expect(item.title, contains('旁路由'));
    });

    test('Android ML Kit block order for the JD router screenshot', () {
      final item = _single([
        'GL°ANet',
        '商品测评',
        '全2.5G网口',
        '有线路由器',
        '8GB EMMC',
        '1GB DDR4',
        'DPI安全防护',
        '弱电箱神器',
        '7月1日-7月31 日',
        '清至高享国补立减5',
        '¥711.55 政府补贴价 ¥749',
        '已售400+',
        '可再享:最高返35京豆 优惠换购',
        '支持迭札物',
        '14.5 4G',
        'MB/s etll',
        'GL-iNet',
        '开通享:续费PLUS会员等,本单省¥28.5',
        '店铺 客服 购物车',
        'l 55',
        '四已选:GL-MT5000有线路由器,1件',
        '加入购物车',
        '●●●',
        '。l0',
        '直播讲解',
        '·视频 图集 口碑',
        '州使用说明',
        'GLINET MT5000有线路由器 软路由交换机企业',
        '旁路由千兆智能迷你网关Q0S 2.5G端口Uv',
        '榜2.5G网口路由器热卖榜·第27名> 全2.5G网口',
        '京东支付己减¥37.45',
        '政府补见o',
        '|政府补贴|剩余补贴额度19996.47元,以结算时具体补… X',
        '|一键迭礼>',
        '补贴后¥711.s5',
        '京东支付下单专享',
        '10',
      ]);

      expect(item.platform, ShoppingPlatform.jd);
      expect(item.price, 711.55);
      expect(item.title, contains('GLINET MT5000'));
      expect(item.title, contains('旁路由'));
    });

    test('iOS Vision places the repeated subsidy price after the title', () {
      final item = _single([
        '¥711.55',
        '已售400+',
        '政府补贴价',
        '¥749',
        '可再享：最高返35京豆',
        'GLINET MT5000有线路由器 软路由交换机企业',
        '旁路由 千兆智能迷你网关QOS 2.5G端口U',
        '榜 2.5G网口路由器热卖榜·第27名',
        '加入购物车',
        '补贴后¥711.55',
        '京东支付下单专享',
      ]);

      expect(item.platform, ShoppingPlatform.jd);
      expect(item.price, 711.55);
      expect(item.title, contains('GLINET MT5000'));
      expect(item.title, contains('旁路由'));
      expect(item.title, isNot(contains('下单专享')));
    });
  });
}

SharedShoppingItem _single(List<String> lines) {
  final items = CartScreenshotParser.parse(lines);
  expect(items, hasLength(1));
  return items.single;
}
