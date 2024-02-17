import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infantique/controllers/userSupportController.dart';
import 'package:infantique/models/userDetails.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class AdminUserSupport extends StatefulWidget {
  const AdminUserSupport({super.key});

  @override
  State<AdminUserSupport> createState() => _AdminUserSupportState();
}

class _AdminUserSupportState extends State<AdminUserSupport> {
  late PageController _pageController;
  int _selectedIndex = 0;
  int _selectedButtonIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Column(
        children: [
          // Row of buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildButton(0, 'Contacts'),
              buildButton(1, 'Issues'),
              buildButton(2, 'Feedbacks'),
            ],
          ),

          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                  _selectedButtonIndex = index;
                });
              },
              children: const [
               ContactUs(),
                Issues(),
                FeedBack(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(int index, String text) {
    return Container(
      decoration: BoxDecoration(
        color:
            _selectedButtonIndex == index ? Colors.grey[400] : Colors.grey[200],
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        onPressed: () {
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
        },
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: _selectedButtonIndex == index
                ? FontWeight.bold
                : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class FeedBack extends StatefulWidget {
  const FeedBack({super.key,});

  @override
  State<FeedBack> createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  UserSupportController supportController = UserSupportController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supportController.fetchFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 50,  // Set the width to control the size
              height: 50, // Set the height to control the size
              child: CircularProgressIndicator(
                value: null, // Set to null to make it indeterminate
                strokeWidth: 2, // Set the stroke width as needed
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error fetching feedbacks: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> feedbacks = snapshot.data!;

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> feedback = feedbacks[index];

                return FutureBuilder(
                  future: fetchUserDetails(feedback['userId']),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          value: null, // Set to null to make it indeterminate
                          strokeWidth: 2, // Set the stroke width as needed
                        ),
                      );
                    } else if (userSnapshot.hasError) {
                      return Text(
                          'Error fetching user details: ${userSnapshot.error}');
                    } else {
                      UserDetails userDetails = userSnapshot.data as UserDetails;
                      final Timestamp timestamp = feedbacks[index]['timestamp'];
                      final DateTime dateTime = timestamp.toDate();

                      final formattedDate = DateFormat.yMMMd().format(dateTime);
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Feedback Details'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Subject:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      feedbacks[index]['subject'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        // Add other styles as needed
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            8), // Add some space between Subject and Description
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    Text(
                                      feedbacks[index]['description'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        // Add other styles as needed
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Submitted',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        '(${userDetails.username})', // Replace formattedTimestamp with your actual timestamp string
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold
                                            // Add other styles as needed
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(14))),
                              child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userDetails.userPicUrl),
                                  ),
                                  title: Text('User: ${userDetails.username}'),
                                  subtitle:
                                      Text('Subject: ${feedback['subject']} '),
                                  trailing: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Icon(Ionicons.open_outline),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(formattedDate),
                                      ])
                                  // Add other feedback details as needed
                                  ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
class Issues extends StatefulWidget {
  const Issues({super.key,});

  @override
  State<Issues> createState() => _IssuesState();
}

class _IssuesState extends State<Issues> {
  UserSupportController supportController = UserSupportController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issues',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24
        ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supportController.fetchIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 50,  // Set the width to control the size
              height: 50, // Set the height to control the size
              child: CircularProgressIndicator(
                value: null, // Set to null to make it indeterminate
                strokeWidth: 2, // Set the stroke width as needed
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error fetching feedbacks: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> issues = snapshot.data!;

            return ListView.builder(
              itemCount: issues.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> issue = issues[index];

                return FutureBuilder(
                  future: fetchUserDetails(issue['userId']),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 50,  // Set the width to control the size
                        height: 50, // Set the height to control the size
                        child: CircularProgressIndicator(
                          value: null, // Set to null to make it indeterminate
                          strokeWidth: 2, // Set the stroke width as needed
                        ),
                      );
                    } else if (userSnapshot.hasError) {
                      return Text(
                          'Error fetching user details: ${userSnapshot.error}');
                    } else {
                      UserDetails userDetails = userSnapshot.data as UserDetails;
                      final Timestamp timestamp = issues[index]['timestamp'];
                      final DateTime dateTime = timestamp.toDate();

                      final formattedDate = DateFormat.yMMMd().format(dateTime);
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Issue Details'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Issue:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      issues[index]['issue'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        // Add other styles as needed
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                        8), // Add some space between Subject and Description



                                    const Text(
                                      'Submitted',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        '(${userDetails.username})', // Replace formattedTimestamp with your actual timestamp string
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold
                                          // Add other styles as needed
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black, width: 1),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(14))),
                              child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(userDetails.userPicUrl),
                                  ),
                                  title: Text('User: ${userDetails.username}'),
                                  subtitle:
                                  Text('Subject: ${issue['issue']} '),
                                  trailing: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Icon(Ionicons.open_outline),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(formattedDate),
                                      ])
                                // Add other feedback details as needed
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  UserSupportController supportController = UserSupportController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: supportController.fetchContact(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 50,  // Set the width to control the size
              height: 50, // Set the height to control the size
              child: CircularProgressIndicator(
                value: null, // Set to null to make it indeterminate
                strokeWidth: 2, // Set the stroke width as needed
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error fetching feedbacks: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> contact = snapshot.data!;

            return ListView.builder(
              itemCount: contact.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> contacts = contact[index];

                return FutureBuilder(
                  future: fetchUserDetails(contacts['userId']),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 50,  // Set the width to control the size
                        height: 50, // Set the height to control the size
                        child: CircularProgressIndicator(
                          value: null, // Set to null to make it indeterminate
                          strokeWidth: 2, // Set the stroke width as needed
                        ),
                      );
                    } else if (userSnapshot.hasError) {
                      return Text(
                          'Error fetching user details: ${userSnapshot.error}');
                    } else {
                      UserDetails userDetails = userSnapshot.data as UserDetails;
                      final Timestamp timestamp = contact[index]['timestamp'];
                      final DateTime dateTime = timestamp.toDate();

                      final formattedDate = DateFormat.yMMMd().format(dateTime);
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Issue Details'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Subject:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      contacts['subject'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        // Add other styles as needed
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                        8),
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      contacts['description'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        // Add other styles as needed
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                        8),
                                    const Text(
                                      'Email:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      contacts['email'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8,),
                                    const Text(
                                      'Phone:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      contacts['phone'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8,),
                                    const Text(
                                      'Submitted',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 14),
                                    ),



                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        '(${userDetails.username})', // Replace formattedTimestamp with your actual timestamp string
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold
                                          // Add other styles as needed
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.black, width: 1),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(14))),
                              child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(userDetails.userPicUrl),
                                  ),
                                  title: Text('User: ${userDetails.username}'),
                                  subtitle:
                                  Text('Subject: ${contacts['subject']} '),
                                  trailing: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Icon(Ionicons.open_outline),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(formattedDate),
                                      ])
                                // Add other feedback details as needed
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

