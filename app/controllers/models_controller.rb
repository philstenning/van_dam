class ModelsController < ApplicationController
  before_action :get_library
  before_action :get_model, except: [:bulk_edit, :bulk_update]

  def show
    @groups = helpers.group(@model.model_files)
  end

  def edit
    @creators = Creator.all
    @model.links.build if @model.links.empty? # populate empty link
  end

  def update_tags(tags)
    old_tags = Set.new(@model.tag_list)
    new_tags = Set.new(tags.reject(&:blank?))

    intersect = old_tags & new_tags
    additions = new_tags.subtract(intersect)
    @model.tag_list = intersect + additions
    @model.save
  end

  def update
    hash = model_params
    tags = hash.delete(:tags)

    if @model.update(hash)
      update_tags(tags.split(",")) if tags
    end

    redirect_to [@library, @model]
  end

  def merge
    if (target = (@model.parents.find { |x| x.id == params[:target].to_i }))
      @model.merge_into! target
      redirect_to [@library, target]
    else
      render status: :bad_request
    end
  end

  def bulk_edit
    @creators = Creator.all
    @models = @library.models
    if (@tag = params[:tag])
      @models = @models.tagged_with(@tag)
    end
  end

  def bulk_update
    hash = bulk_update_params

    add_tags = (hash.delete(:add_tags) { |t| "" }).split(",").reject(&:blank?)
    remove_tags = (hash.delete(:remove_tags) { |t| "" }).split(",").reject(&:blank?)

    add_tags = Set.new(add_tags)
    remove_tags = Set.new(remove_tags)

    params[:models].each_pair do |id, selected|
      if selected == "1"
        model = @library.models.find(id)
        if model.update(hash)
          existing_tags = Set.new(model.tag_list)
          model.tag_list = existing_tags + add_tags - remove_tags
          model.save
        end
      end
    end
    redirect_to edit_library_models_path(@library, tag: params[:tag])
  end

  private

  def bulk_update_params
    params.permit(
      :scale_factor,
      :creator_id,
      :add_tags,
      :remove_tags
    ).compact_blank
  end

  def model_params
    params.require(:model).permit(
      :preview_file_id,
      :creator_id,
      :name,
      :scale_factor,
      :tags,
      links_attributes: [:id, :url, :_destroy]
    )
  end

  def get_library
    @library = Library.find(params[:library_id])
  end

  def get_model
    @model = @library.models.includes(:model_files, :creator).find(params[:id])
    @title = @model.name
  end
end
