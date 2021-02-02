/*
 Navicat Premium Data Transfer

 Source Server         : live_lai
 Source Server Type    : MySQL
 Source Server Version : 50730
 Source Host           : 47.96.173.209:3306
 Source Schema         : live_lai

 Target Server Type    : MySQL
 Target Server Version : 50730
 File Encoding         : 65001

 Date: 26/01/2021 18:04:33
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for anchor_info
-- ----------------------------
DROP TABLE IF EXISTS `anchor_info`;
CREATE TABLE `anchor_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` bigint(12) NULL DEFAULT NULL COMMENT '主播userId',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主播编号',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `nick_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主播昵称',
  `account` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主播账号',
  `identity_code` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '身份证号',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=3234189578,1522186549&fm=26&gp=0.jpg' COMMENT '头像',
  `hand_photo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手持照',
  `audit_status` tinyint(3) NOT NULL DEFAULT 0 COMMENT '主播申请审核状态(0:待审核1: 审核通过 2:审核拒绝)',
  `open_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '微信openid',
  `status` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '参考config表auchor_status字段',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `open_id`(`open_id`) USING BTREE,
  INDEX `is_delete`(`is_delete`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 144 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '主播信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_assistant_info
-- ----------------------------
DROP TABLE IF EXISTS `live_assistant_info`;
CREATE TABLE `live_assistant_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '马甲名称',
  `anchor_id` bigint(12) NOT NULL COMMENT '主播ID',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '主播助手马甲管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_banner_info
-- ----------------------------
DROP TABLE IF EXISTS `live_banner_info`;
CREATE TABLE `live_banner_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'banner名称',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '封面',
  `type` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '跳转类型 0-url 1-app_cms_id',
  `url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'URL',
  `app_cms_id` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'APP_CMS_ID',
  `status` tinyint(3) NOT NULL COMMENT '状态 参考config表banner_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `release_time` datetime(0) NULL DEFAULT NULL COMMENT '发布时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 33 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'banner信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_banner_queue
-- ----------------------------
DROP TABLE IF EXISTS `live_banner_queue`;
CREATE TABLE `live_banner_queue`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '队列名称',
  `type` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '上架类型:0-立即上架,1-定时生效',
  `time` datetime(0) NULL DEFAULT NULL COMMENT '定时上架时间',
  `status` tinyint(3) NOT NULL COMMENT '状态 参考config表queue_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `type`(`type`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `time`(`time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 82 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'banner队列管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_boring_info
-- ----------------------------
DROP TABLE IF EXISTS `live_boring_info`;
CREATE TABLE `live_boring_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '无聊群编码',
  `group_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '无聊群号',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '无聊群名称',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `status` tinyint(3) NOT NULL COMMENT '无聊群状态 参考config表boring_status字段',
  `push_time` datetime(0) NULL DEFAULT NULL COMMENT '推送时间',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `person_num` bigint(12) NULL DEFAULT NULL COMMENT '无聊群人数',
  `push_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送文案',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 153 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播无聊群信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_boring_record
-- ----------------------------
DROP TABLE IF EXISTS `live_boring_record`;
CREATE TABLE `live_boring_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `boring_id` bigint(12) NOT NULL DEFAULT 0 COMMENT '无聊群Id',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `push_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推送文案',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播无聊群推送记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_coupon_info
-- ----------------------------
DROP TABLE IF EXISTS `live_coupon_info`;
CREATE TABLE `live_coupon_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '活动编号',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '活动名称',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '活动图片',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `coupon_id` bigint(12) NOT NULL COMMENT '优惠券id',
  `coupon_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '优惠券名称',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `push_time` datetime(0) NULL DEFAULT NULL COMMENT '推送时间',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `coupon_id`(`coupon_id`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 207 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播优惠券活动信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_coupon_record
-- ----------------------------
DROP TABLE IF EXISTS `live_coupon_record`;
CREATE TABLE `live_coupon_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` bigint(12) NOT NULL COMMENT '用户id',
  `coupon_info_id` bigint(12) NOT NULL COMMENT '优惠券活动ID',
  `status` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '发放状态:0-否,1-是',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 210 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '优惠券发放记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_draw_power_record
-- ----------------------------
DROP TABLE IF EXISTS `live_draw_power_record`;
CREATE TABLE `live_draw_power_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `draw_id` bigint(12) NULL DEFAULT NULL COMMENT '抽奖id',
  `uid` bigint(12) NULL DEFAULT NULL COMMENT '用户ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名称',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `draw_id`(`draw_id`, `uid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 749 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户抽奖资格纪录信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_draw_record
-- ----------------------------
DROP TABLE IF EXISTS `live_draw_record`;
CREATE TABLE `live_draw_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '抽奖记录编码',
  `draw_id` bigint(12) NULL DEFAULT NULL COMMENT '抽奖id',
  `uid` bigint(12) NULL DEFAULT NULL COMMENT '用户ID',
  `address_id` bigint(12) NULL DEFAULT NULL COMMENT '地址id',
  `address` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '地址',
  `status` tinyint(5) NOT NULL DEFAULT 50 COMMENT '奖品状态 参考config表draw_record_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 610 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户中奖纪录信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_home_info
-- ----------------------------
DROP TABLE IF EXISTS `live_home_info`;
CREATE TABLE `live_home_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `sub_title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '副标题',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '封面',
  `times` datetime(0) NULL DEFAULT NULL COMMENT '生效时间',
  `status` tinyint(3) NOT NULL DEFAULT 0 COMMENT '状态 参考config表home_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `times`(`times`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 357 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '首页配置信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_info
-- ----------------------------
DROP TABLE IF EXISTS `live_info`;
CREATE TABLE `live_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '直播间编码',
  `title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '直播标题',
  `label_id` bigint(12) NULL DEFAULT NULL COMMENT '标签ID 对应表live_label_info的 ID  ',
  `label` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标签',
  `person_info` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '直播人员信息(昵称)',
  `square_cover` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '广场封面',
  `home_cover` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '首页封面',
  `main_cover` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '主推封面',
  `spread_bill` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '推广海报',
  `start_time` datetime(0) NOT NULL COMMENT '开播时间',
  `shop_id` bigint(12) NOT NULL COMMENT '商家id',
  `anchor_id` bigint(12) NOT NULL COMMENT '主播id',
  `city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市',
  `stream_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '流名',
  `stream_status` tinyint(3) NULL DEFAULT 0 COMMENT '推流状态 0-暂停 1-恢复',
  `video_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '上传视频地址',
  `push_address` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '推流地址',
  `pull_address` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '播流地址',
  `chat_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '聊天室Id',
  `tchat_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '腾讯IM房间id',
  `lng` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '经度',
  `lat` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '纬度',
  `is_top` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否置顶:0-否,1-是',
  `is_like` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否允许点赞:0-允许,1-不允许',
  `is_comment` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否允许评论:0-允许,1-不允许',
  `is_playback` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否允许回放:0-允许,1-不允许',
  `like_num` bigint(12) NOT NULL DEFAULT 0 COMMENT '点赞数量',
  `comment_num` bigint(12) NULL DEFAULT 0 COMMENT '评论数',
  `browse_num` bigint(12) NULL DEFAULT 0 COMMENT '浏览人数',
  `actual_start_time` datetime(0) NULL DEFAULT NULL COMMENT '实际开播时间',
  `actual_end_time` datetime(0) NULL DEFAULT NULL COMMENT '关播时间',
  `duration` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '0' COMMENT '直播时长',
  `video_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '回放地址',
  `task_id` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '任务录制id',
  `invent_num` int(6) NULL DEFAULT 0 COMMENT '虚拟在线人数',
  `char_address_web` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '聊天室地址，web端',
  `char_address_app` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '聊天室地址，移动端',
  `char_address_wx` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '聊天室地址，微信端',
  `sort` int(4) NOT NULL DEFAULT 0 COMMENT '序号',
  `remark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `audit_status` tinyint(3) NOT NULL DEFAULT 0 COMMENT '直播间审核状态 0-审核中，1审核通过，2审核不通过',
  `status` tinyint(3) NOT NULL COMMENT '直播状态 参考config表live_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `is_hide` tinyint(4) NULL DEFAULT 0 COMMENT '是否隐藏直播间:0-否,1-是',
  `type` tinyint(4) NULL DEFAULT 0 COMMENT '直播间类型:0-APP直播间,1-外卖直播间,2-app和外卖直播间',
  `store_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '门店编号',
  `store_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '门店名称',
  `store_lng` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '门店经度',
  `store_lat` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '门店纬度',
  `live_site` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '直播地点 ',
  `into_type` tinyint(3) NULL DEFAULT NULL COMMENT '内部直播时 进入方式,0-默认1-密码进入 2-内部员工',
  `password` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '直播间密码',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `shop_id`(`shop_id`) USING BTREE,
  INDEX `anchor_id`(`anchor_id`) USING BTREE,
  INDEX `sort`(`sort`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `title`(`title`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 600 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_label_info
-- ----------------------------
DROP TABLE IF EXISTS `live_label_info`;
CREATE TABLE `live_label_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `label` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签名称',
  `sort` int(12) NULL DEFAULT NULL COMMENT '排序',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `label`(`label`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播标签表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_lantern_info
-- ----------------------------
DROP TABLE IF EXISTS `live_lantern_info`;
CREATE TABLE `live_lantern_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '跑马灯消息',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `status` tinyint(3) NOT NULL COMMENT '跑马灯状态 参考config表lantern_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `push_time` datetime(0) NULL DEFAULT NULL,
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 374 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播跑马灯信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_luck_draw
-- ----------------------------
DROP TABLE IF EXISTS `live_luck_draw`;
CREATE TABLE `live_luck_draw`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '抽奖编码',
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '抽奖名称',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `type` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '抽奖类型:0-点赞,1-评论',
  `num` bigint(12) NOT NULL DEFAULT 0 COMMENT '抽奖人数',
  `time` int(4) NOT NULL DEFAULT 0 COMMENT '活动时长(秒)',
  `keyword` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '评论关键词',
  `prize_type` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '奖品类型:0-优惠券,1-实物,2-积分',
  `coupon_id` bigint(12) NULL DEFAULT NULL COMMENT '优惠券id',
  `coupon_img` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `coupon_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '优惠券名称',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `goods_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '实物名称',
  `goods_img` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '实物图片',
  `push_time` datetime(0) NULL DEFAULT NULL COMMENT '推送时间',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `status` tinyint(3) NOT NULL COMMENT '直播状态 参考config表luck_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `is_distinct` tinyint(1) NULL DEFAULT 0 COMMENT '0 不去除重复抽奖 1 去除重复抽奖',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1017 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '抽奖管理信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_notice
-- ----------------------------
DROP TABLE IF EXISTS `live_notice`;
CREATE TABLE `live_notice`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '公告名称',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `template_type` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '公告模板:0-左侧,1-右侧,2-顶部',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '公告图片',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `status` tinyint(3) NOT NULL COMMENT '公告状态 参考config表notice_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 456 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播公告信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_operate_info
-- ----------------------------
DROP TABLE IF EXISTS `live_operate_info`;
CREATE TABLE `live_operate_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `title` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '运营标题',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '运营图片',
  `type` tinyint(1) NOT NULL DEFAULT 0 COMMENT '跳转类型 0-url 1-app_cms_id',
  `url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '跳转路径',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `status` tinyint(3) NOT NULL COMMENT '公告状态 参考config表operate_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `push_time` datetime(0) NULL DEFAULT NULL COMMENT '推屏时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 439 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播运营位信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_play_record
-- ----------------------------
DROP TABLE IF EXISTS `live_play_record`;
CREATE TABLE `live_play_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户id',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `is_delete`(`is_delete`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 257 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '回播观看用户记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_product_info
-- ----------------------------
DROP TABLE IF EXISTS `live_product_info`;
CREATE TABLE `live_product_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `live_id` bigint(12) NULL DEFAULT NULL COMMENT '直播间id',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品编码',
  `sku_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'sku编码',
  `channel_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '渠道编码',
  `product_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品名称',
  `product_photo` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品主图',
  `sku_price` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品原价',
  `price` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品价格',
  `product_href` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品链接',
  `class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '类目',
  `unit_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道编码',
  `sort` int(4) NULL DEFAULT 0 COMMENT '序号',
  `click_num` bigint(12) NULL DEFAULT 0 COMMENT '点击次数',
  `push_time` datetime(0) NULL DEFAULT NULL COMMENT '推送时间',
  `push_num` bigint(12) NULL DEFAULT 0 COMMENT '推送次数',
  `mp_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'mpid',
  `is_top` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否推屏:0-否,1-是',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `remark` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `sort`(`sort`) USING BTREE,
  INDEX `is_top`(`is_top`) USING BTREE,
  INDEX `push_time`(`push_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1518 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家商品管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_queue_banner
-- ----------------------------
DROP TABLE IF EXISTS `live_queue_banner`;
CREATE TABLE `live_queue_banner`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `queue_id` bigint(12) NULL DEFAULT NULL COMMENT '队列模板ID',
  `banner_id` bigint(12) NULL DEFAULT NULL COMMENT 'bannerId',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `queue_id`(`queue_id`) USING BTREE,
  INDEX `banner_id`(`banner_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 279 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'banner模板信息关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_remind_record
-- ----------------------------
DROP TABLE IF EXISTS `live_remind_record`;
CREATE TABLE `live_remind_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户id',
  `live_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '直播间id',
  `status` tinyint(3) NOT NULL COMMENT '状态 0:未提醒 1:已提醒',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `status`(`status`) USING BTREE,
  INDEX `is_delete`(`is_delete`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1077 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '开播提醒记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_report_info
-- ----------------------------
DROP TABLE IF EXISTS `live_report_info`;
CREATE TABLE `live_report_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '受理编号',
  `type_id` bigint(12) NOT NULL COMMENT '违规类型',
  `pic` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '举报图片',
  `content` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '举报内容',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `status` tinyint(3) NOT NULL COMMENT '受理状态 参考config表report_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `type_id`(`type_id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 378 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播间举报信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_report_type
-- ----------------------------
DROP TABLE IF EXISTS `live_report_type`;
CREATE TABLE `live_report_type`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `content` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '违规类型名称',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '举报类型信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_room_count
-- ----------------------------
DROP TABLE IF EXISTS `live_room_count`;
CREATE TABLE `live_room_count`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `comment_num` bigint(12) NULL DEFAULT 0 COMMENT '评论次数',
  `comment_person_num` bigint(12) NULL DEFAULT 0 COMMENT '评论人数',
  `share_num` bigint(12) NULL DEFAULT 0 COMMENT '直播间分享次数',
  `share_person_num` bigint(12) NULL DEFAULT 0 COMMENT '直播间分享人数',
  `watch_num` bigint(12) NULL DEFAULT 0 COMMENT '观看次数',
  `like_num` bigint(12) NULL DEFAULT 0 COMMENT '点赞次数',
  `like_person_num` bigint(12) NULL DEFAULT 0 COMMENT '点赞人数',
  `subscribe_num` bigint(12) NULL DEFAULT 0 COMMENT '订阅次数',
  `close_subscribe_num` bigint(12) NULL DEFAULT 0 COMMENT '取消订阅次数',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  `playback_num` bigint(12) NULL DEFAULT 0 COMMENT '回播次数',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 551 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播数据统计表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_room_record
-- ----------------------------
DROP TABLE IF EXISTS `live_room_record`;
CREATE TABLE `live_room_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `uid` bigint(12) NULL DEFAULT 0 COMMENT '用户id',
  `actual_start_time` datetime(0) NULL DEFAULT NULL COMMENT '实际开播时间',
  `actual_end_time` datetime(0) NULL DEFAULT NULL COMMENT '关播时间',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 456 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_sensitive_words
-- ----------------------------
DROP TABLE IF EXISTS `live_sensitive_words`;
CREATE TABLE `live_sensitive_words`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `content` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '敏感词',
  `type` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '类型:0-基础词库,1-手动维护',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `type`(`type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 329 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '敏感词' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_shop_auchor
-- ----------------------------
DROP TABLE IF EXISTS `live_shop_auchor`;
CREATE TABLE `live_shop_auchor`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `shop_id` bigint(12) NOT NULL COMMENT '商家ID',
  `anchor_id` bigint(12) NOT NULL COMMENT '主播ID',
  `status` tinyint(3) UNSIGNED NULL DEFAULT NULL COMMENT '参考config表shop_auchor_status字段',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `shop_id`(`shop_id`) USING BTREE,
  INDEX `anchor_id`(`anchor_id`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 91 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家主播关联信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_supervise_info
-- ----------------------------
DROP TABLE IF EXISTS `live_supervise_info`;
CREATE TABLE `live_supervise_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `live_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '直播间编号',
  `against_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '违规编码',
  `against_type` tinyint(1) NULL DEFAULT NULL COMMENT '违规类型',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '截图url',
  `status` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '状态:0-待受理  ,1-直播间下架,2-主播禁播 3-已受理',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `live_number`(`live_number`) USING BTREE,
  INDEX `status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播间监管管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_user
-- ----------------------------
DROP TABLE IF EXISTS `live_user`;
CREATE TABLE `live_user`  (
  `id` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户编码',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名称',
  `pic` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT '' COMMENT '用户头像',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `token` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '云信token',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `number`(`number`) USING BTREE,
  INDEX `id`(`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播用户信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_video_record
-- ----------------------------
DROP TABLE IF EXISTS `live_video_record`;
CREATE TABLE `live_video_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `live_id` bigint(12) NULL DEFAULT NULL COMMENT '直播间id',
  `task_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '录播任务id',
  `file_id` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件id',
  `video_url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '文件路径',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 413 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播间录播记录管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_watch_record
-- ----------------------------
DROP TABLE IF EXISTS `live_watch_record`;
CREATE TABLE `live_watch_record`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户id',
  `live_id` bigint(12) NOT NULL COMMENT '直播间ID',
  `source` tinyint(1) NULL DEFAULT 0 COMMENT '用户来源 0.安卓  1.ios.  2.h5   3.小程序',
  `status` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '状态:0-在线,1-离线',
  `city` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '城市',
  `lng` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '经度',
  `lat` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '维度',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `source`(`source`) USING BTREE,
  INDEX `is_delete`(`is_delete`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3122 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播间用户记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for live_white_list
-- ----------------------------
DROP TABLE IF EXISTS `live_white_list`;
CREATE TABLE `live_white_list`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` bigint(12) NULL DEFAULT NULL COMMENT '用户id',
  `live_id` bigint(12) NULL DEFAULT NULL COMMENT '直播间id',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `is_delete`(`is_delete`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '直播间白名单' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for shop_banned
-- ----------------------------
DROP TABLE IF EXISTS `shop_banned`;
CREATE TABLE `shop_banned`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `shop_id` bigint(12) NOT NULL COMMENT '商家id',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `shop_id`(`shop_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家禁播管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for shop_info
-- ----------------------------
DROP TABLE IF EXISTS `shop_info`;
CREATE TABLE `shop_info`  (
  `id` bigint(20) UNSIGNED NOT NULL COMMENT 'ID',
  `number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商家编号ID',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商家名称',
  `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `channel_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '渠道编码',
  `status` bigint(12) NOT NULL COMMENT '商家状态 参考config表shop_status字段',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  `is_delete` tinyint(3) UNSIGNED NULL DEFAULT 0 COMMENT '是否删除:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家管理' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_carousel_figure
-- ----------------------------
DROP TABLE IF EXISTS `sys_carousel_figure`;
CREATE TABLE `sys_carousel_figure`  (
  `id` bigint(12) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `pic` varchar(500) CHARACTER SET gbk COLLATE gbk_chinese_ci NULL DEFAULT NULL COMMENT '图片地址',
  `jump_link` varchar(200) CHARACTER SET gbk COLLATE gbk_chinese_ci NULL DEFAULT NULL COMMENT '跳转地址',
  `sort` smallint(2) NULL DEFAULT 0 COMMENT '排序',
  `config_id` int(12) NULL DEFAULT NULL COMMENT '类型',
  `status` varchar(1) CHARACTER SET gbk COLLATE gbk_chinese_ci NULL DEFAULT 'N' COMMENT '是否可用 Y不可用，N可用',
  `jumpType` varchar(255) CHARACTER SET gbk COLLATE gbk_chinese_ci NULL DEFAULT NULL COMMENT '跳转类型',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `creator` bigint(12) NULL DEFAULT 0 COMMENT '创建人',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '修改时间',
  `updator` bigint(12) NULL DEFAULT 0 COMMENT '修改人',
  `is_delete` varchar(1) CHARACTER SET gbk COLLATE gbk_chinese_ci NOT NULL DEFAULT 'N' COMMENT 'Y 标识已删除 N标识未删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 188 CHARACTER SET = gbk COLLATE = gbk_chinese_ci COMMENT = '轮播图管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `id` bigint(12) NOT NULL AUTO_INCREMENT COMMENT '参数编号',
  `key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数键名',
  `keyNote` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数键名',
  `val` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '参数键值',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '配置分类',
  `pid` bigint(12) NULL DEFAULT NULL COMMENT '上级id',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `creator` bigint(12) NULL DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '修改时间',
  `updator` bigint(12) NULL DEFAULT NULL COMMENT '修改人ID',
  `is_delete` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'N' COMMENT 'Y表示删除  N表示未删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `UK_EAPARAM`(`key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 121 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '全局参数表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for user_ban_info
-- ----------------------------
DROP TABLE IF EXISTS `user_ban_info`;
CREATE TABLE `user_ban_info`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` bigint(12) NOT NULL COMMENT '用户ID',
  `anchor_id` bigint(12) NOT NULL COMMENT '主播ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名称',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `anchor_id`(`anchor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 256 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '主播禁言用户信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_follow
-- ----------------------------
DROP TABLE IF EXISTS `user_follow`;
CREATE TABLE `user_follow`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` bigint(12) NOT NULL COMMENT '用户ID',
  `anchor_id` bigint(12) NOT NULL COMMENT '主播ID',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否取消:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `anchor_id`(`anchor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 212 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户关注信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_follow_live
-- ----------------------------
DROP TABLE IF EXISTS `user_follow_live`;
CREATE TABLE `user_follow_live`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `follow_id` bigint(12) NULL DEFAULT NULL COMMENT '用户关注id',
  `live_id` bigint(12) NULL DEFAULT NULL COMMENT '直播间id',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否取消:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `follow_id`(`follow_id`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 428 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户关注直播间信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_share
-- ----------------------------
DROP TABLE IF EXISTS `user_share`;
CREATE TABLE `user_share`  (
  `id` bigint(12) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `uid` bigint(12) NOT NULL COMMENT '用户ID',
  `live_id` bigint(12) NULL DEFAULT NULL COMMENT '直播间id',
  `type` tinyint(1) NULL DEFAULT NULL COMMENT '分享类型 0:微信 1:支付宝 2:无聊',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `is_delete` tinyint(1) UNSIGNED NULL DEFAULT 0 COMMENT '是否取消:0-否,1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `uid`(`uid`) USING BTREE,
  INDEX `live_id`(`live_id`) USING BTREE,
  INDEX `type`(`type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户分享信息记录' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
