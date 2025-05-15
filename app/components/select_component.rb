# frozen_string_literal: true

class SelectComponent < ViewComponent::Base
  include Searchable
  include Sortable
  include Filterable

  def initialize(name:, options:, selected: nil, placeholder: "Select an option", form: nil, label: nil)
    @name = name
    @options = options
    @selected = selected
    @placeholder = placeholder
    @form = form
    @label = label
  end

  private

  def select_id
    "select-#{@name}-#{object_id}"
  end

  def trigger_classes
    "flex h-10 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
  end

  def options_classes
    "fixed z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover text-popover-foreground shadow-md data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2"
  end
end
