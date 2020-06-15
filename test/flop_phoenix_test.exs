defmodule FlopPhoenixTest do
  use ExUnit.Case
  use Phoenix.HTML

  import FlopPhoenix
  import FlopPhoenix.Factory

  alias Flop.Meta

  doctest FlopPhoenix

  @route_helper_opts [%{}, :pets]

  defp render_pagination(%Meta{} = meta, opts \\ []) do
    meta
    |> pagination(&route_helper/3, @route_helper_opts, opts)
    |> safe_to_string()
  end

  defp route_helper(%{}, path, query) do
    URI.to_string(%URI{path: "/#{path}", query: URI.encode_query(query)})
  end

  describe "pagination/4" do
    test "renders pagination wrapper" do
      result = render_pagination(build(:meta_on_first_page))

      assert String.starts_with?(
               result,
               "<nav aria-label=\"pagination\" class=\"pagination\" " <>
                 "role=\"navigation\">"
             )

      assert String.ends_with?(result, "</nav>")
    end

    test "does not render anything if there is only one page" do
      assert render_pagination(build(:meta_one_page)) == ""
    end

    test "does not render anything if there are no results" do
      assert render_pagination(build(:meta_no_results)) == ""
    end

    test "allows to overwrite wrapper class" do
      result =
        render_pagination(build(:meta_on_first_page),
          wrapper_attrs: [class: "boo"]
        )

      assert result =~
               "<nav aria-label=\"pagination\" class=\"boo\" " <>
                 "role=\"navigation\">"
    end

    test "allows to add attributes to wrapper" do
      result =
        render_pagination(build(:meta_on_first_page),
          wrapper_attrs: [title: "paginate"]
        )

      assert result =~
               "<nav aria-label=\"pagination\" class=\"pagination\" " <>
                 "role=\"navigation\" title=\"paginate\">"
    end

    test "renders previous link" do
      result = render_pagination(build(:meta_on_second_page))

      assert result =~
               "<a class=\"pagination-previous\" " <>
                 "href=\"/pets?page=1&amp;page_size=10\">Previous</a>"
    end

    test "allows to overwrite previous link attributes and content" do
      result =
        render_pagination(
          build(:meta_on_second_page),
          previous_link_attrs: [class: "prev", title: "p-p-previous"],
          previous_link_content:
            content_tag :i, class: "fas fa-chevron-left" do
            end
        )

      assert result =~
               "<a class=\"prev\" href=\"/pets?page=1&amp;page_size=10\" " <>
                 "title=\"p-p-previous\">" <>
                 "<i class=\"fas fa-chevron-left\"></i></a>"
    end

    test "disables previous link if on first page" do
      result = render_pagination(build(:meta_on_first_page))

      assert result =~
               "<span class=\"pagination-previous\" disabled=\"disabled\">" <>
                 "Previous</span>"
    end

    test "allows to overwrite previous link class and content if disabled" do
      result =
        render_pagination(
          build(:meta_on_first_page),
          previous_link_attrs: [class: "prev", title: "no"],
          previous_link_content: "Prev"
        )

      assert result =~
               "<span class=\"prev\" disabled=\"disabled\" title=\"no\">" <>
                 "Prev</span>"
    end

    test "renders next link" do
      result = render_pagination(build(:meta_on_second_page))

      assert result =~
               "<a class=\"pagination-next\" " <>
                 "href=\"/pets?page=3&amp;page_size=10\">Next</a>"
    end

    test "allows to overwrite next link attributes and content" do
      result =
        render_pagination(
          build(:meta_on_second_page),
          next_link_attrs: [class: "next", title: "back"],
          next_link_content:
            content_tag :i, class: "fas fa-chevron-right" do
            end
        )

      assert result =~
               "<a class=\"next\" href=\"/pets?page=3&amp;page_size=10\" " <>
                 "title=\"back\">" <>
                 "<i class=\"fas fa-chevron-right\"></i></a>"
    end

    test "disables next link if on last page" do
      result = render_pagination(build(:meta_on_last_page))

      assert result =~
               "<span class=\"pagination-next\" disabled=\"disabled\">" <>
                 "Next</span>"
    end

    test "allows to overwrite next link attributes and content when disabled" do
      result =
        render_pagination(
          build(:meta_on_last_page),
          next_link_attrs: [class: "next", title: "no"],
          next_link_content:
            content_tag :i, class: "fas fa-chevron-right" do
            end
        )

      assert result =~
               "<span class=\"next\" disabled=\"disabled\" title=\"no\">" <>
                 "<i class=\"fas fa-chevron-right\"></i></span>"
    end

    test "renders page links" do
      result = render_pagination(build(:meta_on_second_page))

      assert result =~ "<ul class=\"pagination-list\">"

      assert result =~
               "<li><a aria-label=\"Goto page 1\" class=\"pagination-link\" " <>
                 "href=\"/pets?page=1&amp;page_size=10\">1</a></li>"

      assert result =~
               "<li><a aria-current=\"page\" aria-label=\"Goto page 2\" " <>
                 "class=\"pagination-link is-current\" " <>
                 "href=\"/pets?page=2&amp;page_size=10\">2</a></li>"

      assert result =~
               "<li><a aria-label=\"Goto page 3\" class=\"pagination-link\" " <>
                 "href=\"/pets?page=3&amp;page_size=10\">3</a></li>"

      assert result =~ "</ul>"
    end

    test "allows to overwrite pagination list attributes" do
      result =
        render_pagination(
          build(:meta_on_first_page),
          pagination_list_attrs: [class: "p-list", title: "boop"]
        )

      assert result =~ "<ul class=\"p-list\" title=\"boop\">"
    end

    test "allows to overwrite pagination link attributes" do
      result =
        render_pagination(
          build(:meta_on_second_page),
          pagination_link_attrs: [class: "p-link", beep: "boop"]
        )

      assert result =~
               "<li>" <>
                 "<a aria-label=\"Goto page 1\" beep=\"boop\" " <>
                 "class=\"p-link\" href=\"/pets?page=1&amp;page_size=10\">" <>
                 "1</a></li>"

      assert result =~
               "<li>" <>
                 "<a aria-current=\"page\" " <>
                 "aria-label=\"Goto page 2\" beep=\"boop\" " <>
                 "class=\"p-link is-current\" " <>
                 "href=\"/pets?page=2&amp;page_size=10\">2</a></li>"
    end

    test "allows to overwrite pagination link aria label" do
      result =
        render_pagination(
          build(:meta_on_second_page),
          pagination_link_aria_label: &"On to page #{&1}"
        )

      assert result =~
               "<li>" <>
                 "<a aria-label=\"On to page 1\" class=\"pagination-link\" " <>
                 "href=\"/pets?page=1&amp;page_size=10\">1</a></li>"

      assert result =~
               "<li>" <>
                 "<a aria-current=\"page\" aria-label=\"On to page 2\" " <>
                 "class=\"pagination-link is-current\" " <>
                 "href=\"/pets?page=2&amp;page_size=10\">2</a></li>"
    end
  end
end
