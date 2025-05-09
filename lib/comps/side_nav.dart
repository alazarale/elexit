import 'package:flutter/material.dart';

class SideNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xffF2F5F8),
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "EL-Test",
                  style: TextStyle(color: Color(0xff0081B9), fontSize: 24),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: Color(0xffF2F5F8),
            ),
          ),
          ListTile(
            leading: Icon(Icons.laptop),
            title: Text('All Exams'),
            onTap: () {
              Navigator.pushNamed(context, '/list',
                  arguments: {'where': 'all'});
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favorite Exams'),
            onTap: () {
              Navigator.pushNamed(context, '/list',
                  arguments: {'where': 'fav'});
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite_border),
            title: Text('Favorite Question'),
            onTap: () {
              Navigator.pushNamed(context, '/fav',
                  arguments: {});
            },
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Store'),
            onTap: () {
              Navigator.pushNamed(context, '/paid',
                  arguments: {'where': 'all'});
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('RQE Setting'),
            onTap: () => {
              Navigator.pushNamed(context, '/random-set',
                  arguments: {})
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Agent'),
            onTap: () => {
              Navigator.pushNamed(context, '/code',
                  arguments: {})
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('How To BUY'),
            onTap: () => {
              Navigator.pushNamed(context, '/how-to',
                  arguments: {})
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact'),
            onTap: () => {
              Navigator.pushNamed(context, '/contact',
                  arguments: {})
            },
          ),
          
          
        ],
      ),
    );
  }
}
