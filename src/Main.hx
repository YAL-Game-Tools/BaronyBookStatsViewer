package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.io.BytesInput;
import js.Browser;
import js.Lib;
import js.html.ArrayBuffer;
import js.html.Event;
import js.html.FileReader;
import js.html.InputElement;
import js.html.DragEvent;
import js.html.TextAreaElement;
import js.html.Uint8ClampedArray;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	static inline function main() {
		function cancelDefault(e:Event) {
			e.preventDefault();
			return false;
		}
		var doc = Browser.document;
		var body = doc.body;
		var current:TextAreaElement = cast doc.getElementById("current");
		var required:TextAreaElement = cast doc.getElementById("required");
		var missing:TextAreaElement = cast doc.getElementById("missing");
		function update() {
			var curr = current.value;
			var amiss = [];
			for (book in required.value.split("\n")) {
				if (curr.indexOf(book) < 0) {
					amiss.push(book);
				}
			}
			missing.value = amiss.join("\n");
		}
		current.onchange = function(_) update();
		body.addEventListener("dragover", cancelDefault);
		body.addEventListener("dragenter", cancelDefault);
		body.addEventListener("drop", function(e:DragEvent) {
			e.preventDefault();
			var dt = e.dataTransfer;
			for (file in dt.files) {
				var reader = new FileReader();
				reader.onloadend = function(_) {
					var abuf:ArrayBuffer = reader.result;
					var input:BytesInput = new BytesInput(Bytes.ofData(abuf));
					if (input.readString(12) != "BARONYSCORES") {
						current.value = "Supplied file doesn't seem to be a valid Barony scores file.";
						return;
					}
					var version = input.readString(6);
					var numBooks = input.readInt32();
					var books:Array<String> = [];
					for (i in 0 ... numBooks) {
						books.push(input.readString(input.readInt32()));
					}
					current.value = books.join("\n");
					update();
				};
				reader.readAsArrayBuffer(file);
			}
			return false;
		});
	}
	
}
