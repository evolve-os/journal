/* Copyright 2014 Ryan Sipes
*
* This file is part of Evolve Journal.
*
* Evolve Journal is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Evolve Journal is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Evolve Journal. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;
using GLib;

namespace EvolveJournal {

	private Window TextFileViewer;
	private string text_buffer_load;

	public class Files {
		
		public string on_open_clicked () {
			var file_chooser = new FileChooserDialog("Open File", TextFileViewer,
				FileChooserAction.OPEN, Stock.CANCEL, ResponseType.CANCEL,
				Stock.OPEN, ResponseType.ACCEPT);
			if (file_chooser.run () == ResponseType.ACCEPT) {
				text_buffer_load = open_file (file_chooser.get_filename ());
			}
			else {
				text_buffer_load = null;
			}
			file_chooser.destroy();
			return text_buffer_load;
		}

		private string open_file (string filename) {
			string text;
			try {
				FileUtils.get_contents(filename, out text);
			} catch (Error e) {
				text = "";
				stderr.printf("Error: %s\n", e.message);
			}
			return text;
		}

		public void on_save_clicked(string text_to_save, EvolveNotebook notebook) {
			var file_chooser = new FileChooserDialog("Save File", TextFileViewer,
				FileChooserAction.SAVE, Stock.CANCEL, ResponseType.CANCEL, Stock.SAVE, ResponseType.ACCEPT);
			file_chooser.set_local_only(true);
			if (file_chooser.run () == ResponseType.ACCEPT){
				try {
					FileUtils.set_contents(file_chooser.get_filename(), text_to_save);
					notebook.set_label(file_chooser.get_current_name());
				}
				catch(Error e) {
					stderr.printf("Error: %s\n", e.message);
				}
			}
			else {
				stdout.printf("FileChooserDialog cancelled.");
			}
			file_chooser.destroy();
		}

	}
}