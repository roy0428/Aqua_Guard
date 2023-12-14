// Reference: https://github.com/JohannesMilke/user_profile_example

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class User {
  final String imagePath;
  final String name;
  final String email;
  final String about;
  final String title;
  final bool isDarkMode;
  
  const User({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.about,
    required this.title,
    required this.isDarkMode,
  });
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  @override
  Widget build(BuildContext context) {
    final user = UserPreferences.myUser;
    return Scaffold(
      // appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: user.imagePath,
            onClicked: () async {},
          ),
          const SizedBox(height: 24),
          buildName(user),
          const SizedBox(height: 24),
          // Center(child: buildUpgradeButton()),
          const SizedBox(height: 24),
          NumbersWidget(),
          const SizedBox(height: 48),
          // buildTitle(user),
          buildAbout(user),
        ],
      ),
    );
  }
  
  Widget buildName(User user) => Column(
        children: [
          Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildAbout(User user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}

AppBar buildAppBar(BuildContext context) {
  final icon = CupertinoIcons.moon_stars;
  return AppBar(
    leading: BackButton(),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: Icon(icon),
        onPressed: () {},
      ),
    ],
  );
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          onPrimary: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: Text(text),
        onPressed: onClicked,
      );
}

class NumbersWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, '5', 'Report Count'),
          buildDivider(),
          buildButton(context, '50', 'Following'),
          buildDivider(),
          buildButton(context, '35', 'Followers'),
        ],
      );

  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) => MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClicked;
  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}

class UserPreferences {
  static const myUser = User(
    imagePath:
        'https://scontent-tpe1-1.xx.fbcdn.net/v/t39.30808-6/375977784_717552333717875_56479752900812814_n.jpg?_nc_cat=104&ccb=1-7&_nc_sid=efb6e6&_nc_ohc=o2t0ufkrFTMAX-l8Lli&_nc_ht=scontent-tpe1-1.xx&oh=00_AfCTJTahp9WWV5CpK5UV7gVHNzRVeL0X4k4barSjjoEvmw&oe=657BA967',
    name: 'CAECE',
    email: 'r12521699@caece.net',
    about:
        "The Computer-Aided Engineering Group (CAE) in the Department of Civil Engineering was established to fulfill the increasing demand for technology-driven solutions in modern civil engineering practice. The Group's educational objective is to cultivate students who possess a multi-disciplinary skill-set that includes both engineering and information technology expertise. The Group's research efforts aim to deepen and broaden understanding in technology-driven engineering with contributions in the automation of civil engineering practice and expansion of the related bodies of knowledge. Conducting research at the CAE is innovative and filled with joy and excitement.",
    title: "Beginner",
    isDarkMode: false,
  );
}
