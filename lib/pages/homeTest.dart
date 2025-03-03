import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/943b3898-c5a3-4abb-bc07-55a035db7a0c",
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
                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/ac591622-b8a3-4c62-8b0d-b5b78a5cc20e",
                                  fit: BoxFit.fill,
                                )),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          margin: const EdgeInsets.only(
                              bottom: 29, left: 23, right: 23),
                          width: double.infinity,
                          child: Row(children: [
                            IntrinsicWidth(
                              child: IntrinsicHeight(
                                child: Container(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Column(children: [
                                    Container(
                                        width: 98,
                                        height: 31,
                                        child: Image.network(
                                          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/30e6638c-66dc-4f26-9c63-a18063356e7e",
                                          fit: BoxFit.fill,
                                        )),
                                  ]),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: SizedBox(),
                              ),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                width: 34,
                                height: 34,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/14899a63-c976-4f0a-9a25-65d569501a5f",
                                      fit: BoxFit.fill,
                                    ))),
                          ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 34, left: 21, right: 21),
                          width: double.infinity,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color(0xFFF8F9FE),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      width: double.infinity,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 8,
                                                    left: 25,
                                                    right: 25),
                                                height: 30,
                                                width: double.infinity,
                                                child: Image.network(
                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/1827f470-13cc-44b5-a6c9-7436d2451cfe",
                                                  fit: BoxFit.fill,
                                                )),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 13),
                                              width: double.infinity,
                                              child: Text(
                                                "Divisions",
                                                style: TextStyle(
                                                  color: Color(0xFF1F2024),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color(0xFFF7F8FD),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      width: double.infinity,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 8,
                                                    left: 25,
                                                    right: 25),
                                                height: 30,
                                                width: double.infinity,
                                                child: Image.network(
                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/021dda6b-8414-4f54-a7bc-6ae357a02aa8",
                                                  fit: BoxFit.fill,
                                                )),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 9),
                                              width: double.infinity,
                                              child: Text(
                                                "Examiners",
                                                style: TextStyle(
                                                  color: Color(0xFF1F2024),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color(0xFFF7F8FD),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      width: double.infinity,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 9,
                                                    left: 25,
                                                    right: 25),
                                                height: 30,
                                                width: double.infinity,
                                                child: Image.network(
                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/969a41a3-dd63-428a-bd76-490cb3db34b1",
                                                  fit: BoxFit.fill,
                                                )),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 13),
                                              width: double.infinity,
                                              child: Text(
                                                "Students",
                                                style: TextStyle(
                                                  color: Color(0xFF1F2024),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: IntrinsicHeight(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color(0xFFF7F8FD),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 13),
                                      width: double.infinity,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 9,
                                                    left: 25,
                                                    right: 25),
                                                height: 30,
                                                width: double.infinity,
                                                child: Image.network(
                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/6e717fa5-2796-4231-8a3b-062a58aff468",
                                                  fit: BoxFit.fill,
                                                )),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              width: double.infinity,
                                              child: Text(
                                                "Exams",
                                                style: TextStyle(
                                                  color: Color(0xFF1F2024),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 66, left: 19, right: 19),
                          width: double.infinity,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IntrinsicHeight(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 13),
                                    width: double.infinity,
                                    child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 17,
                                                  width: double.infinity,
                                                  child: SizedBox(),
                                                ),
                                              ]),
                                          Positioned(
                                            bottom: 0,
                                            left: 8,
                                            width: 122,
                                            height: 14,
                                            child: Container(
                                              transform:
                                                  Matrix4.translationValues(
                                                      0, 1, 0),
                                              child: Text(
                                                "Up Coming Exams",
                                                style: TextStyle(
                                                  color: Color(0xFF1F2024),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                IntrinsicHeight(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 13),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Color(0xFFF7F8FD),
                                              ),
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              width: double.infinity,
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    IntrinsicWidth(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          color:
                                                              Color(0xFFEAF2FF),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 27,
                                                                  bottom: 27,
                                                                  left: 24,
                                                                  right: 24),
                                                          child:
                                                              Column(children: [
                                                            Container(
                                                                width: 32,
                                                                height: 31,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/97bdb826-4859-4cbb-b086-47b8e9fae57a",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 16),
                                                          width:
                                                              double.infinity,
                                                          child: Row(children: [
                                                            Expanded(
                                                              child:
                                                                  IntrinsicHeight(
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          3),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              16),
                                                                  width: double
                                                                      .infinity,
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 10),
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Text(
                                                                            "2nd Year 2nd Semester Economics",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFF1F2024),
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "02/10/2025, 10.00AM - 12.00PM",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xFF71727A),
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16),
                                                                width: 12,
                                                                height: 11,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/923b84c4-d6e0-4e8f-9785-dcbb7472217a",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Color(0xFFF7F8FD),
                                              ),
                                              width: double.infinity,
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    IntrinsicWidth(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          color:
                                                              Color(0xFFEAF2FF),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 27,
                                                                  bottom: 27,
                                                                  left: 24,
                                                                  right: 24),
                                                          child:
                                                              Column(children: [
                                                            Container(
                                                                width: 32,
                                                                height: 31,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/6183d661-8a50-4502-abb1-76c215aa91b1",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 16),
                                                          width:
                                                              double.infinity,
                                                          child: Row(children: [
                                                            Expanded(
                                                              child:
                                                                  IntrinsicHeight(
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          3),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              16),
                                                                  width: double
                                                                      .infinity,
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 10),
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Text(
                                                                            "4th Year 1st Semester Social Science",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFF1F2024),
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "02/10/2025, 10.00AM - 12.00PM",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xFF71727A),
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16),
                                                                width: 12,
                                                                height: 11,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/ca2c6e3b-38f4-481d-9b01-949a5cb27eca",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
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
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Color(0xFFF7F8FD),
                                              ),
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              width: double.infinity,
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    IntrinsicWidth(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          color:
                                                              Color(0xFFEAF2FF),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 27,
                                                                  bottom: 27,
                                                                  left: 24,
                                                                  right: 24),
                                                          child:
                                                              Column(children: [
                                                            Container(
                                                                width: 32,
                                                                height: 31,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/eff4524b-ec78-4a3e-ba1f-c71615a29895",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 16),
                                                          width:
                                                              double.infinity,
                                                          child: Row(children: [
                                                            Expanded(
                                                              child:
                                                                  IntrinsicHeight(
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          3),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              16),
                                                                  width: double
                                                                      .infinity,
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 10),
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Text(
                                                                            "2nd Year 2nd Semester Economics",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFF1F2024),
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "02/10/2025, 10.00AM - 12.00PM",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xFF71727A),
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16),
                                                                width: 12,
                                                                height: 11,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/f90e8f20-c949-496b-8e5f-cbd8dfa4b32e",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Color(0xFFF7F8FD),
                                              ),
                                              width: double.infinity,
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    IntrinsicWidth(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          color:
                                                              Color(0xFFEAF2FF),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 27,
                                                                  bottom: 27,
                                                                  left: 24,
                                                                  right: 24),
                                                          child:
                                                              Column(children: [
                                                            Container(
                                                                width: 32,
                                                                height: 31,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/3a15dc4d-3974-437a-bd5c-62e0e70666ea",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: IntrinsicHeight(
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 16),
                                                          width:
                                                              double.infinity,
                                                          child: Row(children: [
                                                            Expanded(
                                                              child:
                                                                  IntrinsicHeight(
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          3),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              16),
                                                                  width: double
                                                                      .infinity,
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              bottom: 10),
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              Text(
                                                                            "4th Year 1st Semester Social Science",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Color(0xFF1F2024),
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          "02/10/2025, 10.00AM - 12.00PM",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Color(0xFF71727A),
                                                                            fontSize:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ]),
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16),
                                                                width: 12,
                                                                height: 11,
                                                                child: Image
                                                                    .network(
                                                                  "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/ae9086c8-ccd2-434a-84f9-df8d6f80b1dc",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                )),
                                                          ]),
                                                        ),
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
                          width: double.infinity,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: const EdgeInsets.only(left: 167),
                                    width: 24,
                                    height: 24,
                                    child: Image.network(
                                      "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/b2167a5a-5b1e-4331-a222-a20c685cf581",
                                      fit: BoxFit.fill,
                                    )),
                                IntrinsicHeight(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x24939393),
                                          blurRadius: 30,
                                          offset: Offset(0, -5),
                                        ),
                                      ],
                                      gradient: LinearGradient(
                                        begin: Alignment(1, -1),
                                        end: Alignment(1, 1),
                                        colors: [
                                          Color(0xFFFFFFFF),
                                          Color(0xE3FFFFFF),
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(top: 24),
                                    width: double.infinity,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IntrinsicHeight(
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 24),
                                              width: double.infinity,
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          print('Pressed');
                                                        },
                                                        child: IntrinsicHeight(
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              color: Color(
                                                                  0x26C8C8F4),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        3),
                                                            width:
                                                                double.infinity,
                                                            child: Row(
                                                                children: [
                                                                  Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              5),
                                                                      width: 26,
                                                                      height:
                                                                          26,
                                                                      child: Image
                                                                          .network(
                                                                        "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/4af88304-78f6-46b6-a110-df219779aef8",
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      )),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8),
                                                                    child: Text(
                                                                      "Home",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFF4C4DDC),
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            top: 3,
                                                            bottom: 3,
                                                            right: 50),
                                                        width: 26,
                                                        height: 26,
                                                        child: Image.network(
                                                          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/cb014416-957e-40e9-9b71-4bb17ec7eb23",
                                                          fit: BoxFit.fill,
                                                        )),
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            top: 3,
                                                            bottom: 3,
                                                            right: 50),
                                                        width: 26,
                                                        height: 26,
                                                        child: Image.network(
                                                          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/69fe39c6-0c0e-47bc-8088-d4c5b3cc5042",
                                                          fit: BoxFit.fill,
                                                        )),
                                                    Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 3),
                                                        width: 26,
                                                        height: 26,
                                                        child: Image.network(
                                                          "https://figma-alpha-api.s3.us-west-2.amazonaws.com/images/5334b174-8e92-4cc7-a84d-25f403ed89e9",
                                                          fit: BoxFit.fill,
                                                        )),
                                                  ]),
                                            ),
                                          ),
                                          IntrinsicHeight(
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  top: 21, bottom: 8),
                                              width: double.infinity,
                                              child: Column(children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color: Color(0xFF0F0F0F),
                                                  ),
                                                  width: 134,
                                                  height: 5,
                                                  child: SizedBox(),
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
