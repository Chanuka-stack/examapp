import 'package:flutter/material.dart';

class CreateNewStudent extends StatefulWidget {
  const CreateNewStudent({super.key});
  @override
  CreateNewStudentState createState() => CreateNewStudentState();
}

class CreateNewStudentState extends State<CreateNewStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Create New Division"),
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Color(0xFFFFFFFF),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IntrinsicHeight(
                        child: Container(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 12, left: 12, right: 26),
                          width: double.infinity,
                          child: Row(children: [
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                width: 52,
                                height: 21,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.network(
                                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/1fd4ef8c-5366-4c5f-9419-dfd0a925c9bd",
                                      fit: BoxFit.fill,
                                    ))),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: SizedBox(),
                              ),
                            ),
                            Container(
                                width: 66,
                                height: 11,
                                child: Image.network(
                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/cfa5e2e4-0175-4d80-a385-deeedd8a25b2",
                                  fit: BoxFit.fill,
                                )),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          color: Color(0xFFFFFFFF),
                          padding: const EdgeInsets.only(
                              top: 18, bottom: 18, left: 24, right: 120),
                          width: double.infinity,
                          child: Row(children: [
                            Container(
                                width: 20,
                                height: 19,
                                child: Image.network(
                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/7320ca48-df40-440a-983e-399561277db3",
                                  fit: BoxFit.fill,
                                )),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: SizedBox(),
                              ),
                            ),
                            Text(
                              "Create New Student",
                              style: TextStyle(
                                color: Color(0xFF1F2024),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        height: 1,
                        width: double.infinity,
                        child: SizedBox(),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 44, left: 19, right: 19),
                          width: double.infinity,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IntrinsicHeight(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 7),
                                            child: Text(
                                              "Name *",
                                              style: TextStyle(
                                                color: Color(0xFF2E3036),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFFC5C6CC),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              width: double.infinity,
                                              child: Column(children: [
                                                IntrinsicHeight(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    width: 295,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Mr. Shashi F’do",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF1F2024),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 7),
                                            child: Text(
                                              "Index Number *",
                                              style: TextStyle(
                                                color: Color(0xFF2F3036),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFFC5C6CC),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              width: double.infinity,
                                              child: Column(children: [
                                                IntrinsicHeight(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    width: 295,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "EX009472",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF1F2024),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              "Division *",
                                              style: TextStyle(
                                                color: Color(0xFF2E3036),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFFC5C6CC),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.only(
                                                  top: 14,
                                                  bottom: 14,
                                                  left: 16,
                                                  right: 16),
                                              width: double.infinity,
                                              child: Row(children: [
                                                Expanded(
                                                  child: IntrinsicHeight(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4),
                                                      width: double.infinity,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Faculty of Management (FOM)",
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF1F2024),
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    width: 16,
                                                    height: 16,
                                                    child: Image.network(
                                                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/89263da5-8912-4f4b-9ef6-0171c00b2d79",
                                                      fit: BoxFit.fill,
                                                    )),
                                              ]),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    margin: const EdgeInsets.only(bottom: 16),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              "Email Address *",
                                              style: TextStyle(
                                                color: Color(0xFF2E3036),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFFC5C6CC),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              width: double.infinity,
                                              child: Column(children: [
                                                IntrinsicHeight(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    width: 295,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "david@gmail.com",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF1F2024),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 7),
                                            child: Text(
                                              "Contact Number *",
                                              style: TextStyle(
                                                color: Color(0xFF2E3036),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFF3F00FF),
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              width: double.infinity,
                                              child: Column(children: [
                                                IntrinsicHeight(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    width: 295,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "+94 715690876",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF1F2024),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 19, left: 19),
                        child: Text(
                          "Record your index number (3 seconds)*",
                          style: TextStyle(
                            color: Color(0xFF2E3036),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          margin: const EdgeInsets.only(
                              bottom: 33, left: 25, right: 25),
                          width: double.infinity,
                          child: Column(children: [
                            Container(
                              width: 324,
                              child: Text(
                                "Speak clearly and state. This voice recording will be used as your login verification.",
                                style: TextStyle(
                                  color: Color(0xFF71727A),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFF5F5F5),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(39),
                            color: Color(0xFFFFFFFF),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          margin: const EdgeInsets.only(
                              bottom: 66, left: 19, right: 19),
                          width: double.infinity,
                          child: Column(children: [
                            IntrinsicHeight(
                              child: Container(
                                width: 295,
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          width: 37,
                                          height: 37,
                                          child: Image.network(
                                            "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/d6b3a544-6c14-4b21-bcea-dd3d35d0ece5",
                                            fit: BoxFit.fill,
                                          )),
                                      Container(
                                          margin: const EdgeInsets.only(
                                              top: 2, bottom: 2, right: 12),
                                          width: 175,
                                          height: 34,
                                          child: Image.network(
                                            "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/733593d7-7d09-47f2-9706-9afde506cf54",
                                            fit: BoxFit.fill,
                                          )),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Text(
                                          "0:01/0:03",
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 17),
                          width: double.infinity,
                          child: Stack(clipBehavior: Clip.none, children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicHeight(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24),
                                      width: double.infinity,
                                      child: Column(children: [
                                        InkWell(
                                          onTap: () {
                                            print('Pressed');
                                          },
                                          child: IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: Color(0xFFC5C6CC),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              width: 327,
                                              child: Column(children: [
                                                Text(
                                                  "Create",
                                                  style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ]),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: IntrinsicHeight(
                                child: Container(
                                  transform:
                                      Matrix4.translationValues(0, 17, 0),
                                  width: double.infinity,
                                  child: Column(children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Color(0xFF0F0F0F),
                                      ),
                                      margin: const EdgeInsets.only(
                                          top: 21, bottom: 8),
                                      width: 134,
                                      height: 5,
                                      child: SizedBox(),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
