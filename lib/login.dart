import 'package:flutter/material.dart';


// class Login extends StatelessWidget {

//   var pinTextFieldController = TextEditingController();

//   @override
//   void dispose() {
//     // Clean up the controller when the Widget is disposed
//     pinTextFieldController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var loginButton = RaisedButton(
//       child: Text("Login with Twitter"),
//       padding: const EdgeInsets.all(8.0),
//       textColor: Colors.blue,
//       color: Colors.white,
//       onPressed: () {
//         api.getURI().then((res){
//           return api.getAuth().getResourceOwnerAuthorizationURI(res.credentials.token);
//         }).then((address){
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => LoginPage(address: address),
//           ));
//         });            
//       },
//     );
//     var sendPinButton = RaisedButton(
//       child: Text("Verify Code"),
//       padding: const EdgeInsets.all(8.0),
//       textColor: Colors.blue,
//       color: Colors.white,
//       onPressed: (){

//         api.getToken(pinTextFieldController.text).then((res){
//           _setCredentials(res).then((commited){
//           print("Credentials saved");
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => TabBarHome(res.credentials.toString()),
//             ));
//           });
//         });
//       },
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Cheep Login", style: TextStyle(color: Colors.black)), 
//         backgroundColor: Colors.white, 
//         centerTitle: true,),
//       body: Container(
//         child: ListView(shrinkWrap: false, 
//           children: <Widget>[
//             Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Container(padding: EdgeInsets.all(50),
//                   child:Image.asset(
//                     'assets/twitter.png',
//                     width: 100,
//                     height: 100,
//                   ),
//                 ),
//                 // button("Login with Twitter", _lauchLoginPage(context)),
//                 loginButton,
//                 Container(padding: EdgeInsets.all(50), child:Container(child:
//                   TextField(
//                     decoration: InputDecoration(
//                       hintText: 'Please enter PIN',
//                     ),
//                     controller: pinTextFieldController,
//                     maxLength: 7,
//                     textAlign: TextAlign.center,
//                   ),
//                 ),),
//                 sendPinButton,
//                 // button("Verify Code", _verifyCode(context))
//               ]
//             ),
//           ]
//         ),
//       ),
//     );
//   }

//   _lauchLoginPage(context){
//     api.getURI().then((res){
//       return api.getAuth().getResourceOwnerAuthorizationURI(res.credentials.token);
//     }).then((address){
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => LoginPage(address: address),
//       ));
//     });      
//   }

//   _verifyCode(context){
//     api.getToken(pinTextFieldController.text).then((res){
//       _setCredentials(res).then((commited){
//       print("Credentials saved");
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => TabBarHome(res.credentials.toString()),
//         ));
//       });
//     });
//   }
// }