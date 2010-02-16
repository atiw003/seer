module Seer

  # For details on the chart options, see the Google API docs at 
  # http://code.google.com/apis/visualization/documentation/gallery/columnchart.html
  #
  # =USAGE=
  # 
  # In your controller:
  #
  #   @data = Widgets.all # Must be an array of objects that respond to the specidied data method 
  #                       # (In this example, 'quantity'
  #
  # In your view:
  #
  #   <div id="chart" class="chart"></div>
  #
  #   <%= visualize(
  #         @widgets, 
  #         :as => :column_chart,
  #         :in_element => 'chart',
  #         :series => {:label => 'name', :data => 'quantity'},
  #         :chart_options => {
  #           :height   => 300,
  #           :width    => 300,
  #           :is_3_d   => true,
  #           :legend   => 'none',
  #           :colors   => "[{color:'#990000', darker:'#660000'}]",
  #           :title    => "Widget Quantities",
  #           :title_x  => 'Widgets',
  #           :title_y  => 'Quantities'
  #         }
  #       )
  #    -%>
  #   
  # Colors are treated differently for 2d and 3d graphs. If you set is_3_d to false, set the
  # graph color like this:
  #
  #           :colors   => "#990000"
  #
  class PieChart
  
    include Seer::Chart
    
    # Chart options accessors
    attr_accessor :background_color, :border_color, :colors, :data_table, :enable_tooltip, :focus_border_color, :height, :is_3_d, :legend, :legend_background_color, :legend_font_size, :legend_text_color, :pie_join_angle, :pie_minimal_angle, :title, :title_x, :title_y, :title_color, :title_font_size, :tooltip_font_size, :tooltip_height, :tooltip_width, :width
    
    # Graph data
    attr_accessor :label_method, :data_method
    
    def initialize(args={})

      # Standard options
      args.each{ |method,arg| self.send("#{method}=",arg) if self.respond_to?(method) }

      # Chart options
      args[:chart_options].each{ |method, arg| self.send("#{method}=",arg) if self.respond_to?(method) }

      # Handle defaults      
      @colors ||= args[:chart_options][:colors] || DEFAULT_COLORS
      @legend ||= args[:chart_options][:legend] || 'bottom'
      @height ||= args[:chart_options][:height] || '347'
      @width  ||= args[:chart_options][:width] || '556'
      @is_3_d ||= args[:chart_options][:is_3_d]

      @data_table = []
      
    end
  
    def data_table=(data)
      data.each_with_index do |datum, column|
        @data_table << [
          "            data.setValue(#{column}, 0,'#{datum.send(label_method)}');\r",
          "            data.setValue(#{column}, 1, #{datum.send(data_method)});\r"
        ]
      end
    end

    def is_3_d
      @is_3_d.blank? ? false : @is_3_d
    end
    
    def nonstring_options
      [:colors, :enable_tooltip, :height, :is_3_d, :legend_font_size, :pie_join_angle, :pie_minimal_angle, :title_font_size, :tooltip_font_size, :tooltip_width, :width]
    end
    
    def string_options
      [:background_color, :border_color, :focus_border_color, :legend, :legend_background_color, :legend_text_color, :title, :title_color]
    end
    
    def to_js

      %{
        <script type="text/javascript">
          google.load('visualization', '1', {'packages':['piechart']});
          google.setOnLoadCallback(drawChart);
          function drawChart() {
            var data = new google.visualization.DataTable();
#{data_columns(label_method, data_method)}
#{data_table}
            var options = {};
#{options}
            var container = document.getElementById('chart');
            var chart = new google.visualization.PieChart(container);
            chart.draw(data, options);
          }
        </script>
      }
    end
      
    def self.render(data, args)
      graph = Seer::PieChart.new(
        :label_method   => args[:series][:series_label],
        :data_method    => args[:series][:data_method],
        :chart_options  => args[:chart_options],
        :chart_element  => args[:in_element]
      )
      graph.data_table = data
      graph.to_js
    end
    
  end  

end
