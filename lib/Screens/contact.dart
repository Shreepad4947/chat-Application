// import 'dart:html';

import 'package:contacts_service/contacts_service.dart';

import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  // ChatScreen({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Contact> contacts = [];
  List<Contact> contactsFilter = [];
  TextEditingController search = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllContacts();
    search.addListener(() {
      filterContacts();
    });
  }

  // String flattenPhoneNumber(String phoneStr) {
  //   return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
  //     return m[0] == "+" ? "+" : "";
  //   });
  // }

  getAllContacts() async {
    List<Contact> _contacts = (await ContactsService.getContacts(
            withThumbnails: false, photoHighResolution: false))
        .toList();

    setState(() {
      contacts = _contacts;
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];

    _contacts.addAll(contacts);
    if (search.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = search.text.toLowerCase();
        // String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName!.isNotEmpty
            ? contact.displayName!.toLowerCase()
            : '';
        // bool nameMatches = contactName.contains(searchTerm);
        // if (nameMatches == true) {
        //   return true;
        // }

        // if (searchTermFlatten.isEmpty) {
        //   return false;
        // }

        // var phone = contact.phones?.firstWhere((phn) {
        //   String phnFlattened = flattenPhoneNumber(phn.value);
        //   return phnFlattened.contains(searchTermFlatten);
        // }, orElse: () => null);

        return contactName.contains(searchTerm);
        // phone != null;
      });
      setState(() {
        contactsFilter = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = search.text.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        // shadowColor: Colors.blue,
        title: Text("Contacts"),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.cyan[300],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.cyan[50],
                  borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: TextFormField(
                textInputAction: TextInputAction.search,
                controller: search,
                decoration: InputDecoration(
                    hintText: "Search", border: InputBorder.none),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: isSearching == true
                    ? contactsFilter.length
                    : contacts.length,
                itemBuilder: (context, index) {
                  Contact contact = isSearching == true
                      ? contactsFilter[index]
                      : contacts[index];
                  return ListTile(
                      tileColor: Colors.grey[50],
                      focusColor: Colors.cyan[800],
                      title: Container(
                        // color: Colors.blue,
                        // child: Text(contact.displayName.toString()),
                        child: Text(contact.displayName != null
                            //  != null
                            ? contact.displayName.toString()
                            : 'Unknown contact'),
                      ),
                      // title: Text(contact.displayName),

                      // subtitle:
                      //     Text(contact.phones!.elementAt(0).value.toString()),

                      // subtitle: Text(contact.phones.isEmpty != true
                      //     ? contact.phones.elementAt(0).value
                      //     : ''),
                      leading: (contact.avatar != null &&
                              contact.avatar!.length > 0)
                          ? CircleAvatar(
                              // backgroundImage: MemoryImage(contact.avatar),
                              )
                          : CircleAvatar(
                              backgroundColor: Colors.cyan[800],
                              child: Text(contact.initials()),
                            ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
