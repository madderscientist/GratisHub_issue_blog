import '../config.dart';
import 'package:flutter/material.dart';
import '../common.dart';
import '../lazy_notifier.dart';
import '../github_request.dart';
import 'package:url_launcher/url_launcher.dart';
import '../scroll_center.dart';

/// 关于页面 侧边栏
class UserInfoSide {
  // ignore: constant_identifier_names
  static const double AvatarRadius = 64;

  final LazyNotifier<ResponseConfig> sideConfig;
  final String user;
  // 要求改变的个人信息 格式参见下面的注释
  Map<String, dynamic>? modifiedInfo;
  // 平台上的个人信息
  Map<String, dynamic>? githubUserInfo;

  UserInfoSide({
    this.user = Config.owner,
    required this.sideConfig,
    this.modifiedInfo,
  }) {
    getUserInfo(user)
        .then((m) {
          githubUserInfo = m;
          sideConfig.notify();
        })
        .catchError((e) {
          showError(e.toString());
        });
  }

  /// 首先检查modifiedInfo，然后检查githubUserInfo
  dynamic getField(String key) {
    return (modifiedInfo?[key]?.toString()) ??
        (githubUserInfo?[key]?.toString());
  }

  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: sideConfig,
      builder: (context, config, child) {
        final String avatarUrl =
            getField('avatar_url') ??
            'https://avatars.githubusercontent.com/u/0?v=4'; // 默认头像
        final String login = getField('login') ?? user;
        final String bio = getField('bio') ?? '';
        final String? htmlUrl = getField('html_url');

        return CenterOrScroll(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (htmlUrl != null) launchUrl(Uri.parse(htmlUrl));
                  },
                  child: CircleAvatar(
                    radius: AvatarRadius,
                    backgroundImage: NetworkImage(avatarUrl),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(login, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AvatarRadius * 2 * 2,
                ), // 最大宽度为头像2倍
                child: SelectableText(
                  bio,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 示例的用户信息数据格式
// {
//   "login": "madderscientist",
//   "id": 51468627,
//   "node_id": "MDQ6VXNlcjUxNDY4NjI3",
//   "avatar_url": "https://avatars.githubusercontent.com/u/51468627?v=4",
//   "gravatar_id": "",
//   "url": "https://api.github.com/users/madderscientist",
//   "html_url": "https://github.com/madderscientist",
//   "followers_url": "https://api.github.com/users/madderscientist/followers",
//   "following_url": "https://api.github.com/users/madderscientist/following{/other_user}",
//   "gists_url": "https://api.github.com/users/madderscientist/gists{/gist_id}",
//   "starred_url": "https://api.github.com/users/madderscientist/starred{/owner}{/repo}",
//   "subscriptions_url": "https://api.github.com/users/madderscientist/subscriptions",
//   "organizations_url": "https://api.github.com/users/madderscientist/orgs",
//   "repos_url": "https://api.github.com/users/madderscientist/repos",
//   "events_url": "https://api.github.com/users/madderscientist/events{/privacy}",
//   "received_events_url": "https://api.github.com/users/madderscientist/received_events",
//   "type": "User",
//   "user_view_type": "public",
//   "site_admin": false,
//   "name": "Beshar",
//   "company": "Southeast University",
//   "blog": "",
//   "location": "Nanjing",
//   "email": null,
//   "hireable": null,
//   "bio": "EL PSY CONGROO（Student of  Southeast University",
//   "twitter_username": null,
//   "public_repos": 16,
//   "public_gists": 0,
//   "followers": 25,
//   "following": 4,
//   "created_at": "2019-06-07T02:48:34Z",
//   "updated_at": "2025-09-19T12:43:48Z"
// }
