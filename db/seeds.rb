# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([{email: 'admin@lol.ru', password: 'qwerty', admin: true},
             {email: 'user@lol.ru', password: 'qwerty'}])

Good.create([{name: 'FlyKnit Lunar1+ sneakers', main_image_id: '1', user_id: 1},
             {name: 'Neoprene and padded-mesh belt bag', main_image_id: '2', user_id: 1}])

Image.create([{website: 'http://cache.net-a-porter.com/images/products/451271/451271_in_pp.jpg', good_id: 1 },
              {website: 'http://cache.net-a-porter.com/images/products/405801/405801_e1_pp.jpg', good_id: 2 }])

Site.create([{domain: 'net-a-porter.com', name_selector: '#product-details h1', main_image_selector: '#medium-image', images_selector: '', button_selector: '#thumbnails-container img'},
            {domain: 'pandora.net', name_selector: '.info.box h2', main_image_selector: '.images.box img', images_selector: '', button_selector: ''},
            {domain: 'pinterest.com', name_selector: '.detailed h1.commentDescriptionContent', main_image_selector: '.detailed .pinImage', images_selector: '', button_selector: ''},
            {domain: 'wildberries.ru', name_selector: "h3[itemprop='name']", main_image_selector: '#preview-large', images_selector: '', button_selector: '.carousel .MagicThumb-swap'},
            {domain: 'incity.ru', name_selector: '.h1_prod', main_image_selector: '#big_pic', images_selector: '#slider_thumbs img', button_selector: ''}
            ])
