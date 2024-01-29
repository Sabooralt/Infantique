import 'package:flutter/material.dart';
import 'package:infantique/screens/search_screens/ResultScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<String> searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Load search history from SharedPreferences
  Future<void> _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  // Save search query to search history
  Future<void> _saveToSearchHistory(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    searchHistory.insert(0, query);
    if (searchHistory.length > 5) {
      // Keep only the last 5 search queries
      searchHistory = searchHistory.sublist(0, 5);
    }
    prefs.setStringList('searchHistory', searchHistory);
  } // Example suggestions

  // Delete a single search history entry
  Future<void> _deleteSearchHistoryEntry(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.removeAt(index);
      prefs.setStringList('searchHistory', searchHistory);
    });
  }

  Future<void> _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.clear();
      prefs.setStringList('searchHistory', searchHistory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Search History:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Ionicons.trash_outline),
                  onPressed: () {
                    _clearSearchHistory();
                    // Provide feedback for search history cleared
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Search history cleared.'),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            searchHistory.isEmpty
                ? const Text('No search history available.')
                : Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 4.0, // Adjust spacing
                    runSpacing: 4.0,
                    children: searchHistory.map((query) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft),
                          onPressed: () {
                            searchController.text = query;
                          },
                          child: Text(
                            query,
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.black, // Adjust text color if needed
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildSearchBar() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxWidth: 300, // Set a maximum width for the search bar
              maxHeight: 40, // Set a maximum height for the search bar
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: 300,
                    height: 40,// Set a fixed width for the TextField
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {}); // Trigger a rebuild when text changes
                      },
                      textAlignVertical: TextAlignVertical.center, // Center the text vertically
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple), // Colored border
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Adjust contentPadding
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close_outlined),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                            });
                          },
                        )
                            : null,
                      ),
                      style: const TextStyle(fontSize: 16), // Adjust the font size
                      maxLines: 1, // Ensure only one line is visible
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () async{
                      await _saveToSearchHistory(searchController.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultsScreen(query: searchController.text),
                        ),
                      );
                    },
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Customize the text color if needed
                        fontSize: 16, // Adjust the font size
                        decoration: TextDecoration.none, // Remove underline
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}