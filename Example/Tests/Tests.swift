// https://github.com/Quick/Quick

import Quick
import Nimble
import LFramework2

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("LF") {
			let message = "LOG this is a log message."
            it("can print log") {
                expect(LF.log(message)) == message
                expect(LF.log(message, nil)) != ""
                expect(LF.log(message, 42)) != ""
                expect(LF.log(message, "test")) != ""
                expect(LF.log(message, LF.version)) != ""
            }
            it("can show alert") {
                expect(LF.alert(message, 42)) == message
			}
            it("can compare") {
				var i: Int
				i = LF.smaller(1, 2)
				expect(i) == 1
				i = LF.greater(2, 1)
				expect(i) == 2
			}

			context("async calls") {
				it("can dispatch") {
					var i = 0
					LF.dispatch() {
						i = 1
					}
					waitUntil { done in
						NSThread.sleepForTimeInterval(0.5)
						expect(i) == 1
						done()
					}
				}
				it("can dispatch") {
					var i = 0
					LF.dispatch_main() {
						i = 1
					}
					waitUntil { done in
						NSThread.sleepForTimeInterval(0.5)
						expect(i) == 1
						done()
					}
				}
			}
			//	TODO: make it work
			/*
			context("async calls after delay") {
				it("can dispatch") {
					var i = 0
					LF.dispatch_delay(0.1) {
						i = 1
					}
					waitUntil { done in
						NSThread.sleepForTimeInterval(0.5)
						expect(i) == 1
						done()
					}
				}
			}
			*/
		}
        describe("Extensions") {
			context("Array") {
				var array = ["1", "2", "3"]
				it("can remove") {
					expect(array[1]) == "2"
					expect(array[2]) == "3"
					expect(array.remove("2")) == true
					expect(array[1]) == "3"
				}
			}
			context("String") {
				let s = "12345 test"
				var ss = ""
				it("can subscript") {
					var ss = s[1]
					expect(ss) == "2"
					ss = s[1...3]
					expect(ss) == "234"
				}
				it("can count character") {
					expect(s.length) == 10
				}
				it("can process text") {
					expect(s.word_count) == 2
					expect(s.is_email()) == false
					expect("test@na.com".is_email()) == true
				}
				it("can get substring") {
					expect(s.sub_before("45")) == "123"
					expect(s.include("test")) == true
					expect(s.include("TEST")) == false
					expect(s.include("TEST", case_sensitive: false)) == true
					expect(s.remove_whitespace()) == "12345test"
					ss = "Tom &amp; Jerry"
					expect(ss.decode_html()) == "Tom & Jerry"
				}
			}
		}
		/*
        describe("these will fail") {

            it("can do maths") {
                expect(1) == 2
            }

            it("can read") {
                expect("number") == "string"
            }

            it("will eventually fail") {
                expect("time").toEventually( equal("done") )
            }
            
            context("these will pass") {

                it("can do maths") {
                    expect(23) == 23
                }

                it("can read") {
                    expect("🐮") == "🐮"
                }

                it("will eventually pass") {
                    var time = "passing"

                    dispatch_async(dispatch_get_main_queue()) {
                        time = "done"
                    }

                    waitUntil { done in
                        NSThread.sleepForTimeInterval(0.5)
                        expect(time) == "done"

                        done()
                    }
                }
            }
        }
		*/
    }
}