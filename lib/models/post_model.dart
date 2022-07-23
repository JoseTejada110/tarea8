import 'dart:convert';

List<Posts> postsFromJson(String str) =>
    List<Posts>.from(json.decode(str).map((x) => Posts.fromJson(x)));

String postsToJson(List<Posts> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Posts {
  Posts({
    required this.title,
    required this.date,
    required this.description,
    required this.image,
    required this.audio,
  });

  String title;
  DateTime date;
  String description;
  String image;
  String audio;

  factory Posts.fromJson(Map<String, dynamic> json) => Posts(
        title: json["title"] ?? '',
        date: DateTime.parse(json["post_date"].toString()),
        description: json["description"] ?? '',
        image: json["image"] ?? '',
        audio: json["audio"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "post_date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "description": description,
        "image": image,
        "audio": audio,
      };
}
