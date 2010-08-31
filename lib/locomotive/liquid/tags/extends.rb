module Locomotive
  module Liquid
    module Tags
      class Extends < ::Liquid::Extends

        def prepare_parsing
          super

          parent_page = @context[:parent_page]

          @context[:page].merge_editable_elements_from_page(parent_page)

          @context[:snippets] = parent_page.snippet_dependencies
          @context[:templates] = ([*parent_page.template_dependencies] + [parent_page.id]).compact
        end

        private

        def parse_parent_template
          if @template_name == 'parent'
            if @context[:cached_parent]
              @context[:parent_page] = @context[:cached_parent]
              @context[:cached_parent] = nil
            else
              @context[:parent_page] = @context[:page].parent
            end
          else
            @context[:parent_page] = @context[:cached_pages].try(:[], @template_name) ||
              @context[:site].pages.where(:fullpath => @template_name).first
          end

          raise PageNotFound.new("Page with fullpath '#{@template_name}' was not found") if @context[:parent_page].nil?

          @context[:parent_page].template
        end

      end

      ::Liquid::Template.register_tag('extends', Extends)
    end
  end
end