require 'spreadsheet'
module Spree
  class Admin::ExcelsController < Admin::BaseController

    respond_to :html

    def create
      @excel = Excel.new(params[:excel])
      if @excel.save
        # In this example the model MyFile has_attached_file :attachment
        excel_path = "#{RAILS_ROOT}/public/files/excel/#{@excel.id}/#{@excel.attachment_file_name}"
        @workbook = Spreadsheet.open(excel_path)

        # Get the first worksheet in the Excel file
        @worksheet = @workbook.worksheet(0)

        # It can be a little tricky looping through the rows since the variable
        # @worksheet.rows often seem to be empty, but this will work:
        0.upto @worksheet.last_row_index do |index|
          # .row(index) will return the row which is a subclass of Array
          row = @worksheet.row(index)

          # check empty row, but this not work:
          break if row[0].blank?

          @shipment = Shipment.find_by_number(row[3].to_s)
          unless @shipment.nil?
            @shipment.send('ship')
            @shipment.update_attributes(:tracking => row[0].to_s)

          end

          #logger.debug "---------------------------------------"
          #logger.debug "#{row[0]}-#{row[1]}-#{row[2]}-#{row[3]}"
        end

        flash[:notice] = I18n.t(:successfully_created, :resource => 'excels')
      end

      respond_with(@excel) do |format|
        format.html { render :action => 'index' }
      end


    end

  end

end
