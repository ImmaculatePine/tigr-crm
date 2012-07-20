class TasksController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @tasks = Task.order("deadline_date desc")

    if params[:by_name].present?
      @tasks = @tasks.by_name(params[:by_name])
    end
  end
  
  def new
    @task = Task.new
    @task.taskable = Company.find(params[:company_id]) if params[:company_id].present?
    @task.taskable = Person.find(params[:person_id]) if params[:person_id].present?
    @task.deal_id = params[:deal_id] if params[:deal_id].present?
    @task.event_id = params[:event_id] if params[:event_id].present?
  end
  
  def create
    @task = Task.new(params[:task])
    
    if @task.save
      redirect_to task_or_taskable_url(@task), notice: 'Task was successfully created.'
    else
      render "new"
    end
  end
  
  def edit
    @task = Task.find(params[:id])
  end
  
  def update
    @task = Task.find(params[:id])

    if @task.update_attributes(params[:task])
      redirect_to task_or_taskable_url(@task), notice: 'Task was successfully updated.'
    else
      render "edit"
    end
  end
  
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    redirect_to task_or_taskable_url(@task), notice: 'Task was deleted.'
  end

  # Show select file form. No logic with model
  def import_step_1    
  end

  # Save CSV file to database and select columns to import
  def import_step_2
    # Get encoding from params
    case params[:encoding]
      when 'windows-1251' then encoding = 'windows-1251'
      when 'utf-8' then encoding = 'utf-8'
      else encoding = 'utf-8'
    end

    # Get column separator from params
    case params[:col_sep]
      when 'semicolon' then col_sep = ';'
      when 'comma' then col_sep = ','
      when 'tab' then col_sep = '\t'
      else col_sep = ','
    end

    begin
      ActiveRecord::Base.transaction do

        @import = Import.new(Task)

        f = File.open(params[:file].tempfile, "rb:#{encoding}:utf-8")
        # Maybe once I will use this converter to escape quotes
        # converters: lambda do |str| str = str.gsub(/"/,'""') end
        CSV.parse(f, {headers: true, col_sep: col_sep}) do |row|
          
          # Skip blank row
          next if row.to_s.parse_csv.join.blank?

          # Create new ImportRow object
          import_row = @import.import_table.import_rows.create
          
          # Get the attributes from CSV-row and write them to import-row
          row.each do |cell|
            
            header = cell[0].to_s
            data = cell[1].to_s

            import_row.import_cells.create(
              header: header,
              data: data
            )
          end
        end
      end
    rescue ActiveRecord::RecordInvalid
      flash[:error] = t('import.errors.general.error')
      redirect_to tasks_import_step_1_path
      return
    rescue ArgumentError
      flash[:error] = t('import.errors.general.encoding')
      redirect_to tasks_import_step_1_path
      return      
    rescue NoMethodError, CSV::MalformedCSVError
      flash[:error] = t('import.errors.general.incorrect_params')
      redirect_to tasks_import_step_1_path
      return
    end
  end

  # Try to perform the import and render right page
  def import_step_3
    @import = Import.new(Task, params[:import_table], columns: params[:columns])
   
    if @import.save?
      redirect_to tasks_path, notice: t('import.complete')
    else
      render 'import_step_2'
    end
  end

  private

    def task_or_taskable_url(task)
      if task.taskable.nil?
        url = tasks_url
      else
        url = polymorphic_url(task.taskable, anchor: "tasks")
      end
      
      url = deal_url(task.deal, anchor: "tasks") unless task.deal_id.nil?
      url = event_url(task.event, anchor: "tasks") unless task.event_id.nil?
      
      url
    end
end
