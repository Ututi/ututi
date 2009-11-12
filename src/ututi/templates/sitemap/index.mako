<%def name="school_section(school)">
<url>
  <loc>${url(school.url(), qualified=True)}</loc>
  <changefreq>monthly</changefreq>
  <priority>1.0</priority>
</url>
%for child in school.children:
${school_section(child)}
%endfor
</%def>
<%def name="subject_section(subject)">
<url>
  <loc>${url(subject.url(), qualified=True)}</loc>
  <lastmod>${subject.modified_on.date()}</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.8</priority>
</url>
%for page in subject.pages:
  <url>
    <loc>${url(page.url(), qualified=True)}</loc>
    <lastmod>${page.modified_on.date()}</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.7</priority>
  </url>
%endfor
</%def>
<%def name="group_section(group)">
<url>
  <loc>${url(group.url(), qualified=True)}</loc>
  <lastmod>${group.modified_on.date()}</lastmod>
  <changefreq>monthly</changefreq>
  <priority>0.5</priority>
</url>
</%def>
<?xml version='1.0' encoding='UTF-8'?>
<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
        xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
%for school in c.schools:
  ${school_section(school)}
%endfor
%for subject in c.subjects:
  ${subject_section(subject)}
%endfor
%for group in c.groups:
  ${group_section(group)}
%endfor
</urlset>
