import 'package:flutter/material.dart';
import 'package:infantique/controllers/userSupportController.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
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
      appBar: AppBar(
        title: Text('Support Screen'),
      ),
      body: Column(
        children: [
          // Row of buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildButton(0, 'Contact Us'),
              buildButton(1, 'Report Issues'),
              buildButton(2, 'Provide Feedback'),
            ],
          ),

          SizedBox(
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
              children: [
                Contactus(),
                ReportIssuesWidget(),
                FeedbackWidget(),
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
              duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
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

// Custom widgets for each button's content
class Contactus extends StatefulWidget {
  @override
  State<Contactus> createState() => _ContactusState();
}

class _ContactusState extends State<Contactus> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserSupportController supportController = UserSupportController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Add your form or input fields here
            Text(
              'Subject:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: subjectController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Subject is required';
                }
                return null; // Return null for no validation error
              },
              decoration: InputDecoration(
                  hintText: 'Briefly describe the issue or question',
                  hintStyle: TextStyle(
                    fontSize: 12,
                  )),
              maxLines: null,
            ),
            SizedBox(height: 16),
            Text(
              'Email:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                return null; // Return null for no validation error
              },
              decoration: InputDecoration(
                  hintText: 'Enter your email address for communication.',
                  hintStyle: TextStyle(
                    fontSize: 12,
                  )),
              maxLines: 1,
            ),

            const SizedBox(
              height: 16,
            ),
            Text(
              'Phone Number (Optional):',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  hintText:
                      'Enter your phone number if you prefer phone communication.',
                  hintStyle: TextStyle(
                    fontSize: 12,
                  )),
              maxLines: 1,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Description:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: TextFormField(
                controller: descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null; // Return null for no validation error
                },
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                    hintText:
                        'Provide detailed information about the issue or question.',
                    hintStyle: TextStyle(
                      fontSize: 12,
                    )),
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  SubmitContactUs();
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void SubmitContactUs() {
    String subject = subjectController.text;
    String email = emailController.text;
    String? phoneNumber =
        phoneController.text.isNotEmpty ? phoneController.text : null;
    String description = descriptionController.text;

    supportController.SubmitContactUs(subject, description, email, phoneNumber);
  }
}

class ReportIssuesWidget extends StatefulWidget {
  @override
  State<ReportIssuesWidget> createState() => _ReportIssuesWidgetState();
}

class _ReportIssuesWidgetState extends State<ReportIssuesWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserSupportController supportController =
      UserSupportController(); // Index to track the selected button
  TextEditingController issueController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Issues',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Add your form or input fields here
            TextFormField(
              controller: issueController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Describe the issue',
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  submitIssue();
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void submitIssue() {
    String issue = issueController.text;

    supportController.reportIssue(issue);

    issueController.clear();
  }
}

class FeedbackWidget extends StatefulWidget {
  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserSupportController supportController =
      UserSupportController(); // Index to track the selected button
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16, top: 5),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Subject:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: subjectController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Subject is required';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter the subject of your feedback',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Description:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextFormField(
                controller: descriptionController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Provide detailed feedback here',
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitFeedback();
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitFeedback() {
    String subject = subjectController.text;
    String description = descriptionController.text;

    supportController.submitFeedback(subject, description);

    subjectController.clear();
    descriptionController.clear();
  }
}
