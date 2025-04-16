# Swift Student Challenge 2025: Learn by Reading - Chinese Edition

Happy to share my winning submission for the Swift Student Challenge 2025 — an app playground called *Learn by Reading – Chinese Edition*.
It's a simple, focused tool: a PDF reader with on-tap dictionary lookup and translation, built to help intermediate/advanced Chinese learners read content they actually enjoy, like books, short stories, or novels.

## Demo
* Here is a short demo video: https://youtube.com/shorts/PT9LMYptGUk
* Or just some screenshots:
<div>
  <img alt="onboarding slide 1" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/onboarding-0.png?raw=true" width="22%" />
  <img alt="onboarding slide 2" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/onboarding-1.png?raw=true" width="22%" />
  <img alt="onboarding slide 3" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/onboarding-2.png?raw=true" width="22%" />
  <img alt="onboarding slide 4" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/onboarding-3.png?raw=true" width="22%" />
</div>
<div>
  <img alt="pdf view" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/demo-0.png?raw=true" width="30%" />
  <img alt="word view" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/demo-1.png?raw=true" width="30%" />
  <img alt="sentence view - translation" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/demo-2.png?raw=true" width="30%" />
</div>

<div>
  <img alt="sentence view - word breakdown" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/demo-3.png?raw=true" width="30%" />
  <img alt="sentence view - pinyin" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/demo-4.png?raw=true" width="30%" />
  <img alt="dictionary" src="https://github.com/siyusun02/ssc25-learn-by-reading-chinese/screenshots/demo-5.png?raw=true" width="30%" />
</div>



## Background

I've been learning Chinese for a while now, and I'm currently at an early intermediate level. One problem I kept running into is that I understand a lot more when listening than when reading — especially with longer texts like stories or books.

I wanted to bridge that gap by reading Chinese novels, but it quickly became frustrating. Without pinyin or quick dictionary access, it's really hard to figure out how unfamiliar characters are pronounced — and in Chinese, pronunciation is often the key to recognizing meaning.

There are some apps out there that support this kind of assisted reading. But most of them only let you choose from their own curated libraries. That means you can't upload your own content — and I really wanted to read what I like, not just what's offered. Many of these apps were also expensive or subscription-based.

So, I made my own.

## What the App Does

* Open any PDF file — course material, eBooks, scanned worksheets — directly from your device's document library (including iCloud and other sources)
* Tap on any word to view:
  * English definition
  * Pinyin
  * Simplified and traditional forms
  * Text-to-speech playback
  * Similar word suggestions
* Select whole paragraphs to get:
  * Full sentence translation
  * Pinyin view for the entire selection
  * Detailed word-by-word breakdown
  * Built-in dictionary search inside the app
  * Fast and offline-friendly (everything works offline except full sentence translation)

## Technical details
* Built in *SwiftUI*, using the `DocumentGroup` scene for native file integration (Files app, iCloud Drive, etc.)
* Uses `PDFKit` to render PDF documents
* Uses `NaturalLanguage` for word and sentence detection — which is especially tricky in Chinese, since it has no spaces between words
* The [CC-CEDICT](https://www.mdbg.net/chinese/dictionary?page=cedict)  dictionary is converted into an offline SQLite database for fast, local lookups

## How to run
Since the project was created for the Swift Student Challenge, it's packaged as an app playground and can be run directly with Swift Playgrounds (just open the `Learn_by_Reading.swiftpm` file):
    * [Swift playgrounds for iPad](https://apps.apple.com/de/app/swift-playground/id908519492)
    * You can also use Swift Playgrounds for Mac, but some features, as the Translation API, are not available yet (status February 2025)

If you want to test it on an iPhone, you'll need to open the project in Xcode, build it, and run it on a connected device.

## Future plans
I plan to restructure the project, improve the OCR functionality, and eventually build it into a full standalone app. I aim to publish it on at least TestFlight, and hopefully the App Store after some additional polishing.
If you're a chinese language learner and have feature ideas or suggestions, feel free to reach out — I'd love to hear your feedback!

## Credits & Acknowledgements
* Logo and illustrations: all designed by me using SF Symbols and drawing tools
* Dictionary: [CC-CEDICT](https://www.mdbg.net/chinese/dictionary?page=cedict) (licensed under CC BY-SA 4.0)
* Sample story: [Wikipedia 梁山伯與祝英台](https://zh.wikipedia.org/wiki/%E6%A2%81%E5%B1%B1%E4%BC%AF%E8%88%87%E7%A5%9D%E8%8B%B1%E5%8F%B0) 
