module Redcar
  class ApplicationSWT
    class Notebook
      include Redcar::Observable
      
      attr_reader :tab_folder
      
      class CTabFolder2Listener
        def initialize(controller)
          @controller = controller
        end
        
        def close(event)
          if event.item
            tab = @controller.tab_widget_to_tab_model(event.item)
            unless Redcar.app.events.ignore?(:tab_close, tab)
              event.doit = false
              Redcar.app.events.create(:tab_close, tab)
            end
          end
        end
        
        def show_list(event); end
        def maximize(*_); end
        def minimize(*_); end
        def restore(*_); end
      end
      
      class SelectionListener
        def initialize(controller)
          @controller = controller
        end
        
        def widgetSelected(event)
          if event.item
            tab = @controller.tab_widget_to_tab_model(event.item)
            unless Redcar.app.events.ignore?(:tab_focus, tab)
              event.doit = false
              Redcar.app.events.create(:tab_focus, tab)
            end
          end
        end
        
        def widgetDefaultSelected(*_)
        end
      end
      
      def initialize(model, sash)
        @model = model
        @model.controller = self
        create_tab_folder(sash)
        style_tab_folder
        attach_model_listeners
        attach_view_listeners
      end
      
      def create_tab_folder(sash)
        folder_style = Swt::SWT::BORDER + Swt::SWT::CLOSE
        @tab_folder = Swt::Custom::CTabFolder.new(sash, folder_style)
        grid_data = Swt::Layout::GridData.new(Swt::Layout::GridData::FILL_BOTH)
        @tab_folder.set_layout_data(grid_data)
        @tab_folder.pack
      end
      
      def style_tab_folder
        colors = [
          Swt::Graphics::Color.new(ApplicationSWT.display, 230, 240, 255),
          Swt::Graphics::Color.new(ApplicationSWT.display, 170, 199, 246),
          Swt::Graphics::Color.new(ApplicationSWT.display, 135, 178, 247)
        ].to_java(Swt::Graphics::Color)
        percents = [60, 85].to_java(:int)
        
        @tab_folder.setSelectionBackground(colors, percents, true)
      end
      
      def attach_model_listeners
        @model.add_listener(:tab_added) do |tab|
          tab.controller = Redcar.gui.controller_for(tab).new(tab, self)
        end
        @model.add_listener(:tab_moved, &method(:model_event_tab_moved))
      end
      
      def attach_view_listeners
        @tab_folder.add_ctab_folder2_listener(CTabFolder2Listener.new(self))
        @tab_folder.add_selection_listener(SelectionListener.new(self))
      end
      
      # Called by the models when a tab is selected by Redcar.
      def model_event_focus_tab(tab)
        tab_folder.set_selection(tab.item)
        @model.select_tab!(tab.model)
      end

      def model_event_tab_moved(from_notebook, to_notebook, tab_model)
        tab_controller = tab_model.controller
        data           = tab_model.serialize
        tab_controller.set_notebook(to_notebook.controller)
        tab_controller.create_item_widget
        tab_controller.move_tab_widget_to_current_notebook
        tab_controller.focus
        tab_model.deserialize(data)
      end
      
      def dispose
        @tab_folder.dispose
      end
      
      def tab_widget_to_tab_model(tab_widget)
        @model.tabs.detect {|tab| tab.controller.item == tab_widget }
      end

      private
      
      def focussed_tab
        focussed_tab_item = tab_folder.get_selection
        @model.tabs.detect {|tab| tab.controller.item == focussed_tab_item }
      end
      
    end
  end
end
