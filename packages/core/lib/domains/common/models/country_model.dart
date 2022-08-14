/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [
        id,
        name,
      ];
}

List<Country> countries = [
  Country(id: "AFG", name: "Afghanistan"),
  Country(id: "ALB", name: "Albania"),
  Country(id: "DZA", name: "Algeria"),
  Country(id: "ASM", name: "American Samoa"),
  Country(id: "AND", name: "Andorra"),
  Country(id: "AGO", name: "Angola"),
  Country(id: "AIA", name: "Anguilla"),
  Country(id: "ATA", name: "Antarctica"),
  Country(id: "ATG", name: "Antigua And Barbuda"),
  Country(id: "ARG", name: "Argentina"),
  Country(id: "ARM", name: "Armenia"),
  Country(id: "ABW", name: "Aruba"),
  Country(id: "AUS", name: "Australia"),
  Country(id: "AUT", name: "Austria"),
  Country(id: "AZE", name: "Azerbaijan"),
  Country(id: "BHS", name: "Bahamas"),
  Country(id: "BHR", name: "Bahrain"),
  Country(id: "BGD", name: "Bangladesh"),
  Country(id: "BRB", name: "Barbados"),
  Country(id: "BLR", name: "Belarus"),
  Country(id: "BEL", name: "Belgium"),
  Country(id: "BLZ", name: "Belize"),
  Country(id: "BEN", name: "Benin"),
  Country(id: "BMU", name: "Bermuda"),
  Country(id: "BTN", name: "Bhutan"),
  Country(id: "BOL", name: "Bolivia"),
  Country(id: "BIH", name: "Bosnia And Herzegowina"),
  Country(id: "BWA", name: "Botswana"),
  Country(id: "BVT", name: "Bouvet Island"),
  Country(id: "BRA", name: "Brazil"),
  Country(id: "IOT", name: "British Indian Ocean Territory"),
  Country(id: "BRN", name: "Brunei Darussalam"),
  Country(id: "BGR", name: "Bulgaria"),
  Country(id: "BFA", name: "Burkina Faso"),
  Country(id: "BDI", name: "Burundi"),
  Country(id: "KHM", name: "Cambodia"),
  Country(id: "CMR", name: "Cameroon"),
  Country(id: "CAN", name: "Canada"),
  Country(id: "CPV", name: "Cape Verde"),
  Country(id: "CYM", name: "Cayman Islands"),
  Country(id: "CAF", name: "Central African Republic"),
  Country(id: "TCD", name: "Chad"),
  Country(id: "CHL", name: "Chile"),
  Country(id: "CHN", name: "China"),
  Country(id: "CXR", name: "Christmas Island"),
  Country(id: "CCK", name: "Cocos (keeling) Islands"),
  Country(id: "COL", name: "Colombia"),
  Country(id: "COM", name: "Comoros"),
  Country(id: "COG", name: "Congo"),
  Country(id: "COD", name: "Congo, The Democratic Republic Of The"),
  Country(id: "COK", name: "Cook Islands"),
  Country(id: "CRI", name: "Costa Rica"),
  Country(id: "CIV", name: "Cote D&apos;ivoire"),
  Country(id: "HRV", name: "Croatia (local Name: Hrvatska)"),
  Country(id: "CUB", name: "Cuba"),
  Country(id: "CYP", name: "Cyprus"),
  Country(id: "CZE", name: "Czech Republic"),
  Country(id: "DNK", name: "Denmark"),
  Country(id: "DJI", name: "Djibouti"),
  Country(id: "DMA", name: "Dominica"),
  Country(id: "DOM", name: "Dominican Republic"),
  Country(id: "TLS", name: "East Timor"),
  Country(id: "ECU", name: "Ecuador"),
  Country(id: "EGY", name: "Egypt"),
  Country(id: "SLV", name: "El Salvador"),
  Country(id: "GNQ", name: "Equatorial Guinea"),
  Country(id: "ERI", name: "Eritrea"),
  Country(id: "EST", name: "Estonia"),
  Country(id: "ETH", name: "Ethiopia"),
  Country(id: "FLK", name: "Falkland Islands (malvinas)"),
  Country(id: "FRO", name: "Faroe Islands"),
  Country(id: "FJI", name: "Fiji"),
  Country(id: "FIN", name: "Finland"),
  Country(id: "FXX", name: "France, Metropolitan"),
  Country(id: "FRA", name: "France"),
  Country(id: "GUF", name: "French Guiana"),
  Country(id: "PYF", name: "French Polynesia"),
  Country(id: "ATF", name: "French Southern Territories"),
  Country(id: "GAB", name: "Gabon"),
  Country(id: "GMB", name: "Gambia"),
  Country(id: "GEO", name: "Georgia"),
  Country(id: "DEU", name: "Germany"),
  Country(id: "GHA", name: "Ghana"),
  Country(id: "GIB", name: "Gibraltar"),
  Country(id: "GRC", name: "Greece"),
  Country(id: "GRL", name: "Greenland"),
  Country(id: "GRD", name: "Grenada"),
  Country(id: "GLP", name: "Guadeloupe"),
  Country(id: "GUM", name: "Guam"),
  Country(id: "GTM", name: "Guatemala"),
  Country(id: "GIN", name: "Guinea"),
  Country(id: "GNB", name: "Guinea-bissau"),
  Country(id: "GUY", name: "Guyana"),
  Country(id: "HTI", name: "Haiti"),
  Country(id: "HMD", name: "Heard And Mc Donald Islands"),
  Country(id: "VAT", name: "Holy See (vatican City State)"),
  Country(id: "HND", name: "Honduras"),
  Country(id: "HKG", name: "Hong Kong"),
  Country(id: "HUN", name: "Hungary"),
  Country(id: "ISL", name: "Iceland"),
  Country(id: "IND", name: "India"),
  Country(id: "IDN", name: "Indonesia"),
  Country(id: "IRN", name: "Iran (islamic Republic Of)"),
  Country(id: "IRQ", name: "Iraq"),
  Country(id: "IRL", name: "Ireland"),
  Country(id: "ISR", name: "Israel"),
  Country(id: "ITA", name: "Italy"),
  Country(id: "JAM", name: "Jamaica"),
  Country(id: "JPN", name: "Japan"),
  Country(id: "JOR", name: "Jordan"),
  Country(id: "KAZ", name: "Kazakhstan"),
  Country(id: "KEN", name: "Kenya"),
  Country(id: "KIR", name: "Kiribati"),
  Country(id: "PRK", name: "Korea, Democratic People&apos;s Republic Of"),
  Country(id: "KOR", name: "Korea, Republic Of"),
  Country(id: "KWT", name: "Kuwait"),
  Country(id: "KGZ", name: "Kyrgyzstan"),
  Country(id: "LAO", name: "Lao People&apos;s Democratic Republic"),
  Country(id: "LVA", name: "Latvia"),
  Country(id: "LBN", name: "Lebanon"),
  Country(id: "LSO", name: "Lesotho"),
  Country(id: "LBR", name: "Liberia"),
  Country(id: "LBY", name: "Libyan Arab Jamahiriya"),
  Country(id: "LIE", name: "Liechtenstein"),
  Country(id: "LTU", name: "Lithuania"),
  Country(id: "LUX", name: "Luxembourg"),
  Country(id: "MAC", name: "Macau"),
  Country(id: "MKD", name: "Macedonia, The Former Yugoslav Republic Of"),
  Country(id: "MDG", name: "Madagascar"),
  Country(id: "MWI", name: "Malawi"),
  Country(id: "MYS", name: "Malaysia"),
  Country(id: "MDV", name: "Maldives"),
  Country(id: "MLI", name: "Mali"),
  Country(id: "MLT", name: "Malta"),
  Country(id: "MHL", name: "Marshall Islands"),
  Country(id: "MTQ", name: "Martinique"),
  Country(id: "MRT", name: "Mauritania"),
  Country(id: "MUS", name: "Mauritius"),
  Country(id: "MYT", name: "Mayotte"),
  Country(id: "MEX", name: "Mexico"),
  Country(id: "FSM", name: "Micronesia, Federated States Of"),
  Country(id: "MDA", name: "Moldova, Republic Of"),
  Country(id: "MCO", name: "Monaco"),
  Country(id: "MNG", name: "Mongolia"),
  Country(id: "MNE", name: "Montenegro"),
  Country(id: "MSR", name: "Montserrat"),
  Country(id: "MAR", name: "Morocco"),
  Country(id: "MOZ", name: "Mozambique"),
  Country(id: "MMR", name: "Myanmar"),
  Country(id: "NAM", name: "Namibia"),
  Country(id: "NRU", name: "Nauru"),
  Country(id: "NPL", name: "Nepal"),
  Country(id: "NLD", name: "Netherlands"),
  Country(id: "ANT", name: "Netherlands Antilles"),
  Country(id: "NCL", name: "New Caledonia"),
  Country(id: "NZL", name: "New Zealand"),
  Country(id: "NIC", name: "Nicaragua"),
  Country(id: "NER", name: "Niger"),
  Country(id: "NGA", name: "Nigeria"),
  Country(id: "NIU", name: "Niue"),
  Country(id: "NFK", name: "Norfolk Island"),
  Country(id: "MNP", name: "Northern Mariana Islands"),
  Country(id: "NOR", name: "Norway"),
  Country(id: "OMN", name: "Oman"),
  Country(id: "PAK", name: "Pakistan"),
  Country(id: "PLW", name: "Palau"),
  Country(id: "PSE", name: "Palestinian Territory, Occupied"),
  Country(id: "PAN", name: "Panama"),
  Country(id: "PNG", name: "Papua New Guinea"),
  Country(id: "PRY", name: "Paraguay"),
  Country(id: "PER", name: "Peru"),
  Country(id: "PHL", name: "Philippines"),
  Country(id: "PCN", name: "Pitcairn"),
  Country(id: "POL", name: "Poland"),
  Country(id: "PRT", name: "Portugal"),
  Country(id: "PRI", name: "Puerto Rico"),
  Country(id: "QAT", name: "Qatar"),
  Country(id: "REU", name: "Reunion"),
  Country(id: "ROU", name: "Romania"),
  Country(id: "RUS", name: "Russian Federation"),
  Country(id: "RWA", name: "Rwanda"),
  Country(id: "KNA", name: "Saint Kitts And Nevis"),
  Country(id: "LCA", name: "Saint Lucia"),
  Country(id: "VCT", name: "Saint Vincent And The Grenadines"),
  Country(id: "WSM", name: "Samoa"),
  Country(id: "SMR", name: "San Marino"),
  Country(id: "STP", name: "Sao Tome And Principe"),
  Country(id: "SAU", name: "Saudi Arabia"),
  Country(id: "SEN", name: "Senegal"),
  Country(id: "SRB", name: "Serbia"),
  Country(id: "SYC", name: "Seychelles"),
  Country(id: "SLE", name: "Sierra Leone"),
  Country(id: "SGP", name: "Singapore"),
  Country(id: "SVK", name: "Slovakia (slovak Republic)"),
  Country(id: "SVN", name: "Slovenia"),
  Country(id: "SLB", name: "Solomon Islands"),
  Country(id: "SOM", name: "Somalia"),
  Country(id: "SGS", name: "South Georgia And The South Sandwich Islands"),
  Country(id: "ZAF", name: "South Africa"),
  Country(id: "ESP", name: "Spain"),
  Country(id: "LKA", name: "Sri Lanka"),
  Country(id: "SHN", name: "St. Helena"),
  Country(id: "SPM", name: "St. Pierre And Miquelon"),
  Country(id: "SDN", name: "Sudan"),
  Country(id: "SUR", name: "Suriname"),
  Country(id: "SJM", name: "Svalbard And Jan Mayen Islands"),
  Country(id: "SWZ", name: "Swaziland"),
  Country(id: "SWE", name: "Sweden"),
  Country(id: "CHE", name: "Switzerland"),
  Country(id: "SYR", name: "Syrian Arab Republic"),
  Country(id: "TWN", name: "Taiwan"),
  Country(id: "TJK", name: "Tajikistan"),
  Country(id: "TZA", name: "Tanzania, United Republic Of"),
  Country(id: "THA", name: "Thailand"),
  Country(id: "TGO", name: "Togo"),
  Country(id: "TKL", name: "Tokelau"),
  Country(id: "TON", name: "Tonga"),
  Country(id: "TTO", name: "Trinidad And Tobago"),
  Country(id: "TUN", name: "Tunisia"),
  Country(id: "TUR", name: "Turkey"),
  Country(id: "TKM", name: "Turkmenistan"),
  Country(id: "TCA", name: "Turks And Caicos Islands"),
  Country(id: "TUV", name: "Tuvalu"),
  Country(id: "UGA", name: "Uganda"),
  Country(id: "UKR", name: "Ukraine"),
  Country(id: "USA", name: "United States"),
  Country(id: "UMI", name: "United States Minor Outlying Islands"),
  Country(id: "ARE", name: "United Arab Emirates"),
  Country(id: "GBR", name: "United Kingdom"),
  Country(id: "URY", name: "Uruguay"),
  Country(id: "UZB", name: "Uzbekistan"),
  Country(id: "VUT", name: "Vanuatu"),
  Country(id: "VEN", name: "Venezuela"),
  Country(id: "VNM", name: "Viet Nam"),
  Country(id: "VGB", name: "Virgin Islands (british)"),
  Country(id: "VIR", name: "Virgin Islands (u.s.)"),
  Country(id: "WLF", name: "Wallis And Futuna Islands"),
  Country(id: "ESH", name: "Western Sahara"),
  Country(id: "YEM", name: "Yemen"),
  Country(id: "YUG", name: "Yugoslavia"),
  Country(id: "ZMB", name: "Zambia"),
  Country(id: "ZWE", name: "Zimbabwe"),
];
