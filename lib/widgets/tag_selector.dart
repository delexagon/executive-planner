
import 'package:executive_planner/backend/master_list.dart';
import 'package:executive_planner/backend/tag_model.dart';
import 'package:flutter/material.dart';

/// Allows a user to modify an existing event or add a new event.
class TagSelector extends StatefulWidget {
  const TagSelector({
    required this.tags,
    required this.onAdd,
    required this.onRemove,
    Key? key,}) : super(key: key);

  final TagList tags;
  final Function(String t) onAdd;
  final Function(String t) onRemove;

  @override
  _TagSelectorState createState() => _TagSelectorState();
}



class _TagSelectorState extends State<TagSelector> {
  // searchTextEditingController listens for text being typed into tagSelector input
  final TextEditingController _searchTextEditingController =
    TextEditingController();

  String get _searchText => _searchTextEditingController.text.trim();

  // Input box for adding/searching tags
  Widget tagSelector() {
    final Widget tagAdder = TextField(
      controller: _searchTextEditingController,
      textInputAction: TextInputAction.search,
      onSubmitted: (String tag) {
        widget.onAdd(tag);
        setState(() {});
        _searchTextEditingController.clear();
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Add a tag',
      ),
    );

    return tagAdder;
  }

  // Initialize listener
  @override
  void initState() {
    super.initState();
    _searchTextEditingController.addListener(() => refreshState(() {}));
  }

  void refreshState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
  }

  // Displays tag suggestions according to queries from incomplete text being typed in
  // searchTextEditingController sends over the text being typed in, which searches for matching tags in the master tag list in event_list.dart.
  // TODO: Find a way for the master tag list to persist through reloads. Can maybe link to EventList in some way?
  Widget _buildSuggestionWidget() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Suggestions'),
      Wrap(
        children: _filterSearchResultList()
            .where((tagModel) =>
            masterList.hasTag(tagModel) && !widget.tags.contains(tagModel),)
            .map((tagModel) => tagChip(
          tagModel: tagModel,
          onTap: () => {
            setState(() {
              widget.onAdd(tagModel);
              _searchTextEditingController.clearComposing();
            })
          },
          action: 'Add',
          color: Colors.lightBlueAccent,
          accentColor: const Color.fromARGB(255, 54, 149, 193),
        ),)
            .toList(),
      ),
    ],);
  }

  // Displays tag suggestions
  Padding _displayTagWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _filterSearchResultList().isNotEmpty
          ? _buildSuggestionWidget()
          : const Text('No results'),
    );
  }

  // Queries the master tag list based on the text being typed in.
  Iterable<String> _filterSearchResultList() {
    if (_searchText.isEmpty) {
      return masterList.tags();
    }
    return masterList.queryTags(_searchText);
  }

  // Defines how each tag will appear in the tag widget
  Widget tagChip({
    required String tagModel,
    required VoidCallback onTap,
    String? action,
    Color? color,
    Color? accentColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 5.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Text(
                tagModel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          if (action == 'Remove') Positioned(
            right: 0,
            child: CircleAvatar(
              backgroundColor: accentColor,
              radius: 8.0,
              child: const Icon(
                Icons.clear,
                size: 10.0,
                color: Colors.white,
              ),
            ),
          ) else const SizedBox.shrink()
        ],
      ),);
  }

  // Displays selected tags
  Widget tagDisplay() {
    return widget.tags.length > 0
        ? Column(
      children: [
        Wrap(
          children: widget.tags
              .asList()
              .map((tagModel) => tagChip(
            tagModel: tagModel,
            onTap: () => setState(() {
              widget.tags.removeTag(tagModel);
            },),
            action: 'Remove',
            color: Colors.deepOrangeAccent,
            accentColor: Colors.orange.shade600,
          ),)
              .toSet()
              .toList(),
        ),

      ],)
        : Container();
  }

  // Main wrapper for all tag widgets
  Widget tagPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tagDisplay(),
          tagSelector(),
          _displayTagWidget(),
      ],),
    );
  }


  /// Pads text a standard amount.
  Widget paddedText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 0, 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget padded(double vert, double hor, Widget? other) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vert, horizontal: hor),
      child: other,
    );
  }

  // TODO: Let the user collapse features which are used less often.
  @override
  Widget build(BuildContext context) {
    return tagPicker();
  }
}
