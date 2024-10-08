// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mustaqim/core/blog_card.dart';
import 'package:mustaqim/core/button_form.dart';
import 'package:mustaqim/core/colors.dart';
import 'package:mustaqim/core/drawer_tile.dart';
import 'package:mustaqim/core/drawer_tile2.dart';
import 'package:mustaqim/core/styles_text.dart';
import 'package:mustaqim/models/blog_model.dart';
import 'package:mustaqim/screens/admin_blogs_screen.dart';
import 'package:mustaqim/screens/auth/login_screen.dart';
import 'package:mustaqim/screens/blog_screen.dart';
import 'package:mustaqim/screens/comments_screen.dart';
import 'package:mustaqim/screens/favorites_screen.dart';
import 'package:mustaqim/screens/my_blogs_screen.dart';
import 'package:mustaqim/screens/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<BlogModel> listOfBlogs;
  bool isPageLoading = true;
  bool isAdmin = false;
  final String linkedInUrl = 'https://www.linkedin.com/in/anes-hellalet/';

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  // bool isAdmin = ;

  @override
  void initState() {
    initPage();
    super.initState();
  }

  void initPage() async {
    setState(() {
      isPageLoading = true;
    });

    await firestore
        .collection("blogs")
        .orderBy("createdAt", descending: true)
        .get()
        .then((collection) {
      final lsitOfDocs = collection.docs;
      final listOfJson = lsitOfDocs.map((doc) {
        return doc.data();
      });

      listOfBlogs = listOfJson.map((json) {
        return BlogModel.fromJson(json);
      }).toList();
    });

    //* read user model
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      // No user is signed in, redirect to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    if (mounted) {
      setState(() {
        isPageLoading = false;
      });
    }
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(
          FirebaseAuth.instance.currentUser!.uid,
        )
        .get();

    // Check if the document exists and if the 'isAdmin' field is available
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        isAdmin = userDoc['isAdmin'] as bool? ?? false;
        // ^ The local 'isAdmin' variable is assigned the value from Firestore
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        initPage();
      },
      child: Scaffold(
        drawer: Drawer(
          width: 225,
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: Image.asset(
                  'assets/images/app_icon_scaled.png',
                  fit: BoxFit.scaleDown,
                ),
              ),
              Container(
                height: 2,
                color: ColorsApp.blackColor,
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      DrawerTile(
                        text: "Profile",
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ));
                        },
                        iconT: Icons.person,
                      ),
                      DrawerTile(
                        text: "My Favorite",
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ));
                        },
                        iconT: Icons.favorite_rounded,
                      ),
                      DrawerTile(
                        text: "My Comments",
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const CommentsScreen(),
                          ));
                        },
                        iconT: Icons.comment_rounded,
                      ),
                      DrawerTile(
                        text: "My Blogs",
                        function: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyBlogsScreen(),
                          ));
                        },
                        iconT: Icons.photo_camera_back_rounded,
                      ),
                      const Spacer(),
                      DrawerTile2(
                        iconT: Icons.call_rounded,
                        text: "Contact us",
                        function: () async {
                          final Uri url = Uri.parse(linkedInUrl);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            // Handle the case where the URL can't be opened
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Could not open LinkedIn profile')),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        body: isPageLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 80,
                        width: MediaQuery.of(context).size.width,
                        color: ColorsApp.whiteColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(
                              builder: (context) => InkWell(
                                onTap: () {
                                  Scaffold.of(context).openDrawer();
                                },
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    color: ColorsApp.whiteColor,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.more_horiz_rounded,
                                      size: 25,
                                      color: ColorsApp.blueColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (isAdmin) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminBlogsScreen(),
                                  ));
                                  CherryToast.success(
                                    description: Text(
                                      "You Have Admin Access Now !",
                                      style: TextStyleForms.headLineStyle03,
                                    ),
                                  ).show(context);
                                } else {
                                  CherryToast.error(
                                    description: Text(
                                      "You Don't Have Access For That !",
                                      style: TextStyleForms.headLineStyle03,
                                    ),
                                  ).show(context);
                                }
                              },
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.asset(
                                  'assets/images/app_icon_scaled.png',
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                await FirebaseAuth.instance.signOut();

                                CherryToast.success(
                                  description:
                                      const Text("SIGNED OUT SUCCESSFULLY!"),
                                ).show(context);

                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ));
                              },
                              child: Container(
                                height: 70,
                                width: 70,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  color: ColorsApp.whiteColor,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.exit_to_app_rounded,
                                    size: 25,
                                    color: ColorsApp.blueColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: ColorsApp.blueColor,
                    ),
                  ),
                  isPageLoading
                      ? const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            itemCount: listOfBlogs.length,
                            itemBuilder: (context, index) {
                              return BlogCard(
                                userId: listOfBlogs[index].userId,
                                idBlog: listOfBlogs[index].id,
                                madeAt: listOfBlogs[index].createdAt,
                                titleText: listOfBlogs[index].title,
                                descriptionText:
                                    listOfBlogs[index].description.trim(),
                                imageUrl: listOfBlogs[index].imageUrl.trim(),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BlogScreen(
                                        blogModel: listOfBlogs[index],
                                      ),
                                    ),
                                  );
                                },
                                listOfLikes: listOfBlogs[index].listOfLikes,
                              );
                            },
                          ),
                        ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 3,
                        color: ColorsApp.blueColor,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80,
                        color: ColorsApp.whiteColor,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: ButtonForm(
                              buttonT: "Create Blog",
                              function: null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
