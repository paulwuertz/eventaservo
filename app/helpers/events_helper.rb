# frozen_string_literal: true

module EventsHelper
  def event_like_button(event)
    return icon('fas', 'heart', event.likes.count) unless user_signed_in?

    button_class = current_user.liked?(event) ? 'button-like-pressed' : 'button-like'
    link_to event.likes.count, event_toggle_like_path(event.code), class: button_class
  end

  def event_participant_button(event)
    unless user_signed_in?
      return icon('fas', 'user-check', pluralize(event.participants.count, 'partoprenanto', 'partoprenantoj'))
    end

    button_class = current_user.participant?(event) ? 'button-participant-pressed' : 'button-participant'
    link_to event.participants.count, event_toggle_participant_path(event.code), class: button_class
  end

  def display_events_by_style
    case cookies[:vidmaniero]
    when 'kalendaro'
      render partial: 'events/events_as_calendar', locals: { events: @events + @today_events }
    when 'mapo'
      render partial: 'events/events_as_map', locals: { events: @events + @today_events }
    else
      render partial: 'events/events_as_cards', locals: { events: @events }
    end
  end

  def event_flag(event)
    return unless event.country.code

    flag_icon(event.country.code)
  end

  def event_map_url(event)
    "https://www.google.com/maps/search/?api=1&query=#{event.full_address}"
  end

  def days_to_event(event)
    if event.date_start < Time.zone.today && event.date_end >= Time.zone.today
      0
    else
      Integer(event.date_start.to_date - Time.zone.today)
    end
  end

  def event_map_pin_color(event)
    case days_to_event(event)
    when -30..0 then 'greenIcon'
    when 1..7 then 'orangeIcon'
    when 8..30 then 'yellowIcon'
    else 'blueIcon'
    end
  end

  def event_color_class(event)
    case days_to_event(event)
    when 0 then 'event-color-today'
    when 1..7 then 'event-color-7days'
    when 8..30 then 'event-color-30days'
    when 31..Float::INFINITY then 'event-color-future'
    else 'event-color-past'
    end
  end

  # Protektas la retadreson kontaŭ spamoj
  def display_event_email(event)
    if user_signed_in?
      mail_to(event.email, event.email, subject: "Informoj pri la evento #{event.title}", class: 'button-contact')
    else
      event.email.gsub('@', ' <ĉe> ').gsub('.', ' <punkto> ')
    end
  end

  def link_to_event_count(periodo, organizo, speco, &_block)
    active_class =
      if params[:periodo].present?
        params[:periodo] == periodo ? 'ec-active' : 'ec-inactive'
      end

    link_to url_for(periodo: (periodo unless params[:periodo] == periodo), o: organizo, s: speco),
            class: "event-count #{periodo} #{active_class}" do
      yield
    end
  end
end
